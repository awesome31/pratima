#!/usr/bin/env ruby
# Builds the site from src/ into site/.
#   ruby build.rb
# Pages live in src/pages/*.erb. Shared header, footer, drawings and marks are below.
# Copy comes from COPY.md verbatim; visual rules come from DESIGN.md.

require 'erb'
require 'fileutils'

ROOT = File.expand_path(__dir__)
SRC  = File.join(ROOT, 'src')
OUT  = File.join(ROOT, 'site')

LINKEDIN = 'https://www.linkedin.com/in/pratimajain'
# Contact form: messages are sent to a Google Form behind the site's own form.
# Paste the Google Form's "pre-filled link" between the quotes (made with the sample
# answers  name / email / message ), then run  ruby build.rb .
# Leave empty until then; the form shows its "didn't send" message and points to LinkedIn.
GOOGLE_FORM_LINK = 'https://docs.google.com/forms/d/e/1FAIpQLSdzy7iUfXdh8xqSPtyKXtjMxU5qw8A3WraTEWLWKC7kJXtf0Q/viewform?usp=pp_url&entry.1529213743=name&entry.555728283=email&entry.2011192346=message'

PAGES = [
  { src: 'index.erb',    out: 'index.html',          key: 'home',     depth: 0,
    title: 'Pratima Jain | Learning Experience Designer in Mumbai',
    desc:  'Pratima Jain is a learning experience designer in Mumbai who cares most about how people learn. Ideas and experiments on AI in learning design, plus speaking and teaching.' },
  { src: 'about.erb',    out: 'about/index.html',    key: 'about',    depth: 1,
    title: 'About Pratima Jain | From Pharmacist to Learning Designer at TCS',
    desc:  "Pratima Jain's path from pharmacist to learning experience designer and project lead at Tata Consultancy Services (TCS), and why she calls herself a learning engineer in the making." },
  { src: 'ideas.erb',    out: 'ideas/index.html',    key: 'ideas',    depth: 1,
    title: 'Ideas & Experiments: Learning Ecosystems, Reels and Learning Games | Pratima Jain',
    desc:  'Six ideas on how people learn, from learning ecosystems to microlearning vs reels, and three experiments, including a financial literacy game, by learning experience designer Pratima Jain.' },
  { src: 'speaking.erb', out: 'speaking/index.html', key: 'speaking', depth: 1,
    title: 'Speaking & Teaching: AI Workshops, Public Speaking, Life Sciences | Pratima Jain',
    desc:  'Pratima Jain speaks and teaches on AI fluency, learning design and public speaking: AI workshops for L&D teams, university sessions, and life sciences events in India. Based in Mumbai.' },
  { src: 'contact.erb',  out: 'contact/index.html',  key: 'contact',  depth: 1,
    title: 'Contact Pratima Jain',
    desc:  'Contact Pratima Jain, learning experience designer in Mumbai. Connect on LinkedIn or leave a message, especially if one of her ideas got you thinking.' },
  { src: '404.erb',      out: '404.html',            key: 'lost',     depth: :abs,
    title: 'Page not found | Pratima Jain',
    desc:  'This page has wandered off.' }
].freeze

NAV = [['about', 'About', 'I'], ['ideas', 'Ideas', 'II'], ['speaking', 'Speaking', 'III'], ['contact', 'Contact', '']].freeze

class Page
  def initialize(meta)
    @meta = meta
  end

  def h(text)
    text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
  end

  # Relative link to a path from the site root, so the site works from any folder.
  def r(path = '')
    prefix = @meta[:depth] == :abs ? '/' : ('../' * @meta[:depth])
    out = prefix + path
    out.empty? ? './' : out
  end

  def key
    @meta[:key]
  end

  def render
    body = ERB.new(File.read(File.join(SRC, 'pages', @meta[:src])), trim_mode: '-').result(binding)
    @body = body
    ERB.new(File.read(File.join(SRC, 'layout.erb')), trim_mode: '-').result(binding)
  end

  # ---------- Components ----------

  def hello(start = 0, extra = '')
    %(<button class="sticker sticker--hello #{extra}" type="button" data-greeting data-start="#{start}" aria-label="Hello"><span class="sticker__txt" aria-hidden="true" lang="en">Hello</span></button>)
  end

  def num(n)
    %(<span class="sticker sticker--num" aria-hidden="true">#{n}</span>)
  end

  def linkedin(label = 'Connect on LinkedIn')
    %(<a class="btn btn--li" href="#{LINKEDIN}" target="_blank" rel="noopener"><span class="li-mark" aria-hidden="true"><span>in</span></span><span>#{label}</span><span class="vh"> opens in a new tab</span><span class="arrow" aria-hidden="true"></span>#{spark}</a>)
  end

  def arrow
    '<span class="arrow" aria-hidden="true"></span>'
  end

  def photo(name, alt, sizes, portrait: true, eager: false)
    w, hgt = portrait ? [1067, 1600] : [1600, 1067]
    sw = portrait ? [600, 1067] : [900, 1600]
    %(<img src="#{r("assets/img/#{name}-900.jpg")}" srcset="#{r("assets/img/#{name}-900.jpg")} #{sw[0]}w, #{r("assets/img/#{name}-1600.jpg")} #{sw[1]}w" sizes="#{sizes}" width="#{w}" height="#{hgt}" alt="#{h(alt)}"#{eager ? ' fetchpriority="high"' : ' loading="lazy"'} decoding="async">)
  end

  # Reads the Google Form id and the three field ids out of the pre-filled link.
  def form_attrs
    link = GOOGLE_FORM_LINK.strip
    return '' if link.empty?

    id = link[%r{/forms/d/e/([^/]+)/}, 1]
    fields = %w[name email message].map do |key|
      entry = link[/(entry\.\d+)=#{key}(?:&|$)/i, 1]
      abort "GOOGLE_FORM_LINK: could not find the field pre-filled with '#{key}'." unless entry
      %(data-entry-#{key}="#{entry}")
    end
    abort 'GOOGLE_FORM_LINK: could not find the form id.' unless id
    %(data-action="https://docs.google.com/forms/d/e/#{id}/formResponse" #{fields.join(' ')})
  end

  # One row of an index list. With a description it opens on hover, focus or tap.
  def row(name, tag = nil, desc = nil, art = nil)
    sup = tag ? %(<sup>#{tag}</sup>) : ''
    nm = %(<span class="row__name d-m">#{name}#{sup}</span>)
    return %(<li class="row"><div class="row__btn">#{nm}</div></li>) unless desc

    pic = art ? %(<div class="row__art">#{art}</div>) : ''
    %(<li class="row"><button class="row__btn" type="button" aria-expanded="false">#{nm}<span class="row__plus" aria-hidden="true"></span></button><div class="row__more"><div>#{pic}<p class="r-m">#{desc}</p></div></div></li>)
  end

  def index_list(heading, rows, cls: '', side: nil, count: true)
    counter = count ? %(<span class="sec-head__count d-m" aria-hidden="true">#{rows.size}</span>) : ''
    aside = side ? %(<div class="index__side"><p class="r-m">#{side}</p></div>) : ''
    line = cls.include?('index--path') ? path_line : ''
    %(<section class="index #{cls}" data-io><div class="sec-head"><h2 class="d-m">#{heading}</h2>#{counter}</div><div class="index__body">#{aside}<div class="index__rows">#{line}<ul>#{rows.join}</ul></div></div></section>)
  end

  def figures
    items = [
      [100, 'international participants in soft skills training', false],
      [200, 'participants across 40+ trainings on pharmaceutical drugs', true],
      [70,  'people trained on AI basics and fluency', false],
      [15,  'university students taught public speaking', false]
    ].map do |n, caption, ringed|
      number = %(<span class="fig__n" data-count="#{n}" data-suffix="+">#{n}+</span>)
      number = %(<span class="fig__n"><span class="mark mark--circle" data-count="#{n}" data-suffix="+">#{n}+<svg aria-hidden="true" viewBox="0 0 200 100" preserveAspectRatio="none"><path d="M104 9 C44 4 7 26 8 52 C10 82 62 95 110 92 C162 89 197 70 192 44 C187 17 138 3 78 12"/></svg></span></span>) if ringed
      %(<li>#{number}<span class="fig__c util">#{caption}</span></li>)
    end
    %(<ul class="figures" data-io>#{items.join}</ul><p class="figures__note r-m">And a few more audiences at occasional workshops.</p>)
  end

  def work_with_me
    rows = ['AI-for-learning workshops', 'Learning design consulting',
            'Guest lectures, visiting faculty sessions and university workshops', 'Talks and mentoring'].map { |t| row(t) }
    index_list('Work with me', rows, cls: 'index--quiet', side: 'Things you can approach me for.', count: false)
  end

  # ---------- Hand-drawn marks (a tidy grown-up pen) ----------

  def underline(text)
    %(<span class="mark mark--underline" data-io>#{text}<svg aria-hidden="true" viewBox="0 0 200 12" preserveAspectRatio="none"><path d="M2 7 C28 2 52 11 86 6 S152 2 198 8"/></svg></span>)
  end

  def strike(text)
    %(<span class="mark mark--strike">#{text}<svg aria-hidden="true" viewBox="0 0 200 12" preserveAspectRatio="none"><path d="M2 8 C44 3 96 10 198 4"/></svg></span>)
  end

  def circle(text, attrs = '')
    %(<span class="mark mark--circle" #{attrs}>#{text}<svg aria-hidden="true" viewBox="0 0 200 100" preserveAspectRatio="none"><path d="M104 9 C44 4 7 26 8 52 C10 82 62 95 110 92 C162 89 197 70 192 44 C187 17 138 3 78 12"/></svg></span>)
  end

  def pen_arrow(cls = '')
    %(<svg class="pen #{cls}" aria-hidden="true" viewBox="0 0 140 70"><path pathLength="1" d="M6 60 C30 18 86 8 128 30"/><path pathLength="1" style="--i:1" d="M108 14 L130 31 L104 44"/></svg>)
  end

  def pen_arrow_down(cls = '')
    %(<svg class="pen #{cls}" aria-hidden="true" viewBox="0 0 100 70"><path pathLength="1" d="M92 6 C70 4 40 14 22 44"/><path pathLength="1" style="--i:1" d="M12 24 L20 48 L44 40"/></svg>)
  end

  def bracket
    %(<svg class="pen" aria-hidden="true" viewBox="0 0 16 100" preserveAspectRatio="none"><path d="M13 3 C4 6 7 40 3 50 C8 61 4 94 13 97"/></svg>)
  end

  def spark
    %(<svg class="spark" aria-hidden="true" viewBox="0 0 30 30"><path d="M5 22 L10 14"/><path d="M15 20 L16 6"/><path d="M24 23 L28 12"/></svg>)
  end

  def tick
    %(<svg class="doodle" aria-hidden="true" viewBox="0 0 40 40"><path pathLength="1" d="M6 22 C10 24 14 30 16 34 C20 22 28 10 36 5"/></svg>)
  end

  def path_line
    %(<svg class="path-line" aria-hidden="true" viewBox="0 0 14 400" preserveAspectRatio="none"><path d="M7 2 C11 40 3 82 8 124 C12 168 2 210 7 252 C11 296 3 338 7 398"/></svg>)
  end

  # ---------- Childlike drawings (thick wobbly crayon line, shapes that don't quite close) ----------

  def doodle(name, alt)
    box, paths = DOODLES.fetch(name)
    lines = paths.each_with_index.map { |dd, i| %(<path pathLength="1" style="--i:#{i}" d="#{dd}"/>) }.join
    %(<svg class="doodle" role="img" aria-label="#{h(alt)}" viewBox="#{box}">#{lines}</svg>)
  end

  DOODLES = {
    # A medicine capsule, an arrow, a pencil
    capsule: ['0 0 330 170', [
      'M44 62 C22 65 20 103 45 107 L100 109 C125 105 123 63 98 59 L47 61',
      'M70 59 L72 109',
      'M30 74 L62 69 L33 84 L64 82 L36 95 L64 95 L44 103',
      'M140 86 C162 79 180 91 204 83',
      'M190 70 L207 83 L192 98',
      'M238 124 L293 46 L310 60 L253 137 L237 125',
      'M238 124 L229 149 L253 137',
      'M229 149 L235 142',
      'M284 58 L302 72'
    ]],
    # A stick figure beside a board, with an empty speech bubble
    speaker: ['0 0 300 225', [
      'M112 34 L272 27 L278 134 L116 142 L111 36',
      'M132 142 L124 196',
      'M258 136 L266 193',
      'M136 64 L242 58',
      'M138 88 L212 84',
      'M140 110 L228 105',
      'M54 74 C37 74 31 96 45 106 C59 114 75 104 73 88 C71 78 63 72 51 75',
      'M46 84 L47 86',
      'M60 83 L61 85',
      'M45 93 C51 100 59 99 63 91',
      'M53 109 L55 164',
      'M54 127 L25 143',
      'M54 125 L98 98',
      'M55 164 L35 205',
      'M55 164 L77 203',
      'M70 20 C51 17 43 40 60 49 L57 64 L72 51 C97 55 105 30 90 22 C84 18 76 19 69 21'
    ]],
    # A dice and a small stack of coins
    dice: ['0 0 260 200', [
      'M30 62 L112 54 L120 138 L36 146 L29 64',
      'M50 79 c-6 0 -6 10 1 10 c6 0 6 -10 -1 -10',
      'M95 73 c-6 0 -6 10 1 10 c6 0 6 -10 -1 -10',
      'M74 97 c-6 0 -6 10 1 10 c6 0 6 -10 -1 -10',
      'M54 120 c-6 0 -6 10 1 10 c6 0 6 -10 -1 -10',
      'M99 114 c-6 0 -6 10 1 10 c6 0 6 -10 -1 -10',
      'M160 98 C160 85 226 83 228 98 C228 112 162 112 160 99',
      'M160 99 L161 118 C164 132 226 130 228 116 L228 98',
      'M161 118 L162 138 C166 152 228 150 229 136 L228 116',
      'M162 138 L163 158 C168 172 230 168 230 154 L229 136',
      'M196 38 C180 38 178 66 194 68 C212 70 214 42 198 37',
      'M190 46 L200 50 L189 54 L200 58 L192 61'
    ]],
    # A smiling box-shaped robot beside a stick figure
    robot: ['0 0 280 225', [
      'M80 48 L78 26',
      'M78 26 c-7 0 -7 -11 0 -11 c7 0 7 11 0 11',
      'M40 52 L120 48 L124 112 L42 116 L39 54',
      'M62 70 c-7 0 -7 12 1 12 c7 0 7 -12 -1 -12',
      'M100 68 c-7 0 -7 12 1 12 c7 0 7 -12 -1 -12',
      'M60 94 C72 106 92 104 104 92',
      'M50 124 L112 120 L116 182 L52 186 L49 126',
      'M62 138 L100 134 L64 148 L102 146 L66 160 L102 158',
      'M50 142 L26 158',
      'M114 140 L142 128',
      'M66 186 L64 210',
      'M98 184 L100 209',
      'M210 80 C194 80 190 102 204 110 C220 116 232 102 228 90 C226 82 218 78 208 81',
      'M202 90 L203 92',
      'M217 89 L218 91',
      'M201 99 C207 106 215 105 220 97',
      'M210 112 L212 166',
      'M211 128 L184 134',
      'M211 128 L238 144',
      'M212 166 L194 206',
      'M212 166 L232 204'
    ]],
    # A megaphone with a star coming out of it
    megaphone: ['0 0 295 200', [
      'M40 112 L48 86 L150 46 L162 152 L52 120 L41 113',
      'M150 46 C168 62 172 132 162 152',
      'M70 124 L78 162 L98 158 L92 130',
      'M58 96 L128 70 L60 106 L134 88 L64 114 L140 108',
      'M184 74 L204 62',
      'M188 102 L212 102',
      'M184 130 L204 142',
      'M252 22 L259 43 L281 43 L263 56 L270 78 L252 64 L233 79 L240 56 L223 44 L245 43 L253 23'
    ]]
  }.freeze
end

PAGES.each do |meta|
  out = File.join(OUT, meta[:out])
  FileUtils.mkdir_p(File.dirname(out))
  File.write(out, Page.new(meta).render)
  puts "built #{meta[:out]}"
end
