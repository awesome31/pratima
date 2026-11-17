#!/usr/bin/env ruby
# The website editor: a small local web app for changing the site's words and photos.
#   ruby editor/server.rb        (or double-click "Edit my website.command")
#
# It only listens on this computer (127.0.0.1). It reads and writes content/site.json,
# rebuilds the pages with build.rb, and can commit and push with git.

require 'webrick'
require 'json'
require 'open3'
require 'fileutils'
require 'tmpdir'
require 'uri'

ROOT    = File.expand_path('..', __dir__)
CONTENT = File.join(ROOT, 'content', 'site.json')
HISTORY = File.join(ROOT, 'content', 'history')
IMAGES  = File.join(ROOT, 'site', 'assets', 'img')
PORT    = (ENV['PORT'] || 4174).to_i
PHOTOS  = { 'standing' => 'pratima-standing', 'laptop' => 'pratima-laptop', 'seated' => 'pratima-seated' }.freeze
SECTIONS = %w[shared home about ideas speaking contact].freeze
KEEP_HISTORY = 40

def run(*cmd, env: {})
  out, status = Open3.capture2e(env, *cmd, chdir: ROOT)
  [out.to_s.force_encoding('UTF-8').scrub, status.success?]
end

def reply(res, body, status = 200)
  res.status = status
  res['Content-Type'] = 'application/json; charset=utf-8'
  res['Cache-Control'] = 'no-store'
  res.body = JSON.generate(body)
end

# Only this computer's own editor page may change anything.
def trusted?(req)
  host = req['Host'].to_s
  req['X-Editor'] == '1' && (host.start_with?('localhost:') || host.start_with?('127.0.0.1:'))
end

def read_content
  File.read(CONTENT, encoding: 'UTF-8')
end

def backups
  Dir[File.join(HISTORY, 'site-*.json')].sort
end

def git_state
  changes, = run('git', 'status', '--porcelain')
  last, = run('git', 'log', '-1', '--format=%cd', '--date=format:%d %b %Y, %H:%M')
  { unpublished_changes: !changes.strip.empty?, last_commit: last.strip, undo_steps: backups.size }
end

server = WEBrick::HTTPServer.new(
  Port: PORT, BindAddress: '127.0.0.1', AccessLog: [],
  Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN)
)

server.mount('/preview', WEBrick::HTTPServlet::FileHandler, File.join(ROOT, 'site'))
server.mount('/', WEBrick::HTTPServlet::FileHandler, __dir__)

server.mount_proc('/api/content') do |_req, res|
  res['Content-Type'] = 'application/json; charset=utf-8'
  res['Cache-Control'] = 'no-store'
  res.body = read_content
end

server.mount_proc('/api/status') { |_req, res| reply(res, git_state) }

server.mount_proc('/api/save') do |req, res|
  next reply(res, { ok: false, error: 'Not allowed.' }, 403) unless req.request_method == 'POST' && trusted?(req)

  begin
    content = JSON.parse(req.body.to_s.force_encoding('UTF-8'))
    raise 'The content is missing a section.' unless content.is_a?(Hash) && SECTIONS.all? { |k| content[k].is_a?(Hash) }
  rescue StandardError => e
    next reply(res, { ok: false, error: "That could not be saved: #{e.message}" }, 400)
  end

  FileUtils.mkdir_p(HISTORY)
  previous = read_content
  backup = File.join(HISTORY, "site-#{Time.now.strftime('%Y%m%d-%H%M%S')}.json")
  File.write(backup, previous)
  File.write(CONTENT, JSON.pretty_generate(content) + "\n")
  out, ok = run('ruby', 'build.rb')
  unless ok
    File.write(CONTENT, previous)
    File.delete(backup)
    run('ruby', 'build.rb')
    next reply(res, { ok: false, error: "The pages could not be rebuilt, so nothing was changed.\n\n#{out[-600..-1] || out}" }, 500)
  end
  backups[0...-KEEP_HISTORY].each { |f| File.delete(f) } if backups.size > KEEP_HISTORY
  reply(res, { ok: true }.merge(git_state))
end

server.mount_proc('/api/undo') do |req, res|
  next reply(res, { ok: false, error: 'Not allowed.' }, 403) unless req.request_method == 'POST' && trusted?(req)

  latest = backups.last
  next reply(res, { ok: false, error: 'There is nothing to undo.' }, 400) unless latest

  File.write(CONTENT, File.read(latest, encoding: 'UTF-8'))
  File.delete(latest)
  out, ok = run('ruby', 'build.rb')
  reply(res, { ok: ok, error: ok ? nil : out }.merge(git_state))
end

server.mount_proc('/api/photo') do |req, res|
  next reply(res, { ok: false, error: 'Not allowed.' }, 403) unless req.request_method == 'POST' && trusted?(req)

  # WEBrick does not parse the address's ?slot= for uploads, so read it directly.
  slot = URI.decode_www_form(req.query_string.to_s).to_h['slot']
  name = PHOTOS[slot]
  next reply(res, { ok: false, error: 'Unknown photo.' }, 400) unless name
  next reply(res, { ok: false, error: 'No photo was received.' }, 400) if req.body.to_s.empty?

  Dir.mktmpdir do |dir|
    upload = File.join(dir, 'upload')
    File.binwrite(upload, req.body)
    info, ok = run('sips', '-g', 'pixelWidth', upload)
    next reply(res, { ok: false, error: 'That file is not a photo this Mac can read. Try a JPG, PNG or HEIC.' }, 400) unless ok && info.include?('pixelWidth')

    # Resize into the temporary folder first; the live photos are only replaced if both sizes worked.
    sizes = [1600, 900]
    done = sizes.all? do |size|
      out = File.join(dir, "#{size}.jpg")
      _, good = run('sips', '-s', 'format', 'jpeg', '-s', 'formatOptions', '74', '-Z', size.to_s, upload, '--out', out)
      good && File.size?(out)
    end
    sizes.each { |size| FileUtils.cp(File.join(dir, "#{size}.jpg"), File.join(IMAGES, "#{name}-#{size}.jpg")) } if done
    reply(res, { ok: done, error: done ? nil : 'That file could not be used as a photo. Try a JPG, PNG or HEIC.' }.merge(git_state))
  end
end

server.mount_proc('/api/publish') do |req, res|
  next reply(res, { ok: false, error: 'Not allowed.' }, 403) unless req.request_method == 'POST' && trusted?(req)

  target = JSON.parse(req.body.to_s)['target'] rescue nil
  branch = { 'preview' => 'new-site', 'live' => 'main' }[target]
  next reply(res, { ok: false, error: 'Unknown choice.' }, 400) unless branch

  log = []
  run('git', 'add', '-A')
  staged, = run('git', 'diff', '--cached', '--name-only')
  unless staged.strip.empty?
    out, ok = run('git', 'commit', '-m', "Update website, #{Time.now.strftime('%-d %b %Y %H:%M')}")
    log << out
    next reply(res, { ok: false, error: "The changes could not be recorded.\n\n#{out}" }, 500) unless ok
  end
  out, ok = run('git', 'push', 'origin', "HEAD:#{branch}", env: { 'GIT_TERMINAL_PROMPT' => '0' })
  log << out
  needs_signin = !ok && out.match?(/could not read Username|Authentication failed|Invalid username|403|denied/i)
  reply(res, { ok: ok, needs_signin: needs_signin, branch: branch, output: log.join("\n").strip }.merge(git_state))
end

url = "http://localhost:#{PORT}/"
trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }
Thread.new do
  sleep 0.6
  puts "\n  The website editor is running at #{url}"
  puts "  Leave this window open while you edit. Close it (or press Control-C) when you are done.\n\n"
  system('open', url) unless ENV['NO_OPEN']
end
server.start
