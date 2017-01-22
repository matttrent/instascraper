require 'slugify'
require 'digest'
require 'mechanize'

HTML_PATH 		      = ENV['HTML_PATH']
MARKDOWN_PATH       = ENV['MARKDOWN_PATH']
INSTAPAPER_EMAIL    = ENV['INSTAPAPER_EMAIL']
INSTAPAPER_PASSWORD = ENV['INSTAPAPER_PASSWORD']

class Instascraper
  def initialize(username, password = '')
    @agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }

    @agent.get('https://www.instapaper.com/user/login') do |page|
      form = page.form
      form.texts.first.value = username
      form.password = password
      form.submit
    end
  end
  
  def bookmarks(path = '/u')
    
    bookmarks = []
    more_pages = true
    current_page = 1
    
    while more_pages do
      page = @agent.get("https://www.instapaper.com#{path}/#{current_page}")

      puts path + " " + current_page.to_s

      page.parser.css('.article_item').each do |bookmark|
        # puts bookmark.css('.article_title').first['title']
        
        bookmarks << Bookmark.new(bookmark, @agent)  
      end

      if page.link_with :text => /Older Articles/
        current_page += 1
      else
        more_pages = false
      end
    end

    return bookmarks
  end

  class Bookmark
    attr_reader :link
    attr_reader :title
    attr_reader :text
    attr_reader :agent

    def initialize(dom_element, agent)
      @link = dom_element.css('.article_title').first['href']
      @title = dom_element.css('.article_title').first['title']
      @text = 'http://www.instapaper.com' + @link

      @agent = agent
    end

    def html
      @html ||= @agent.get(@text).parser.css('#story')
    end

  end
end


def download_bookmarks(bookmarks)

	bookmarks.each do |bookmark|

		filename = "%s-%d.html" % [
			bookmark.title.slugify(trim=true), 
			bookmark.link.split('/')[-1]
		]

		if filename[0] == "-"
			filename = filename[1..-1]
		end

		filepath = "#{HTML_PATH}/#{filename}"

		next if File.exist?(filepath)
    next if bookmark.html.size == 0

		print "ADDING " + filename + "\n"

		target = open(filepath, 'w')
		target.write(bookmark.html)
		target.close

		sleep(Random.rand * 4)
	end

end


def html_to_markdown

	Dir.glob("#{HTML_PATH}/*.html").sort.each do |f|
	
	  next if !File.size?(f)

	  new_filename = File.basename(f, File.extname(f)) + ".md"
	  new_filepath = MARKDOWN_PATH + "/" + new_filename
		
	  if !File.exist?(new_filepath)
		  puts "MARKYING " + new_filename
			marky = "./marky.rb -o #{MARKDOWN_PATH} -f htmlfile #{f}"
			m_return = system(marky)
		  sleep(Random.rand * 2)
		else
			# puts "EXISTS" + new_filename
		end
	end
end


i = Instascraper.new(INSTAPAPER_EMAIL, INSTAPAPER_PASSWORD)

puts "SCRAPING"
unread_bookmarks = i.bookmarks("/u")
# archive_bookmarks = i.bookmarks("/archive")
puts "DOWNLOADING"
download_bookmarks(unread_bookmarks)
# download_bookmarks(archive_bookmarks)
puts "MARKDOWNING"
html_to_markdown
