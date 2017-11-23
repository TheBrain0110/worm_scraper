# encoding: utf-8

require 'optparse'
require 'nokogiri'
require 'open-uri'
require 'uri'

@pact_url="https://pactwebserial.wordpress.com/category/story/arc-1-bonds/1-01/"
@twig_url="https://twigserial.wordpress.com/2014/12/24/taking-root-1-1/"
@worm_url="https://parahumans.wordpress.com/2011/06/11/1-1/"
@ward_url="https://www.parahumans.net/2017/10/21/glow-worm-0-1/"

story = { "pact" => @pact_url, "twig" => @twig_url, "worm" => @worm_url, "ward" => @ward_url}

options = []
OptionParser.new do |opts|
	opts.banner = "Usage: serial_scrape.rb [options]"

	opts.on("-s", "--series NAME", "Select web series") do |name|
		options << name
	end

	opts.on("-a", "select all") do 
		options = ["worm", "pact", "twig", "ward"]
	end
end.parse!

def write_story(starting_chapter)
	@next_chapter = starting_chapter
	@toc = "<h1>Table of Contents</h1>"
	@book_body = ""
	@index = 1
	while @next_chapter
    #check if url is weird
    if @next_chapter.to_s.include?("½")
      @next_chapter = URI.escape(@next_chapter)
    end
    if @next_chapter.to_s.start_with?("//")
      @next_chapter = "https:" + @next_chapter
    end
    #converts http to https to prevent ruby2.3's problem with open_loop redirection
    @next_chapter.sub! "http://", "https://"
    doc = Nokogiri::HTML(open(@next_chapter))
    #get
    @chapter_title = doc.css('h1.entry-title').first #html formatted

    #modify chapter to have link
    @chapter_title_plain = @chapter_title.content
    $stderr.puts @chapter_title_plain
    @chapter_content = doc.css('div.entry-content').first #gsub first p
    #clean
    @chapter_content.search('.//div').remove
    @to_remove = doc.css('div.entry-content p').first #gsub first p
    @chapter_content = @chapter_content.to_s.gsub(@to_remove.to_s,"")
    #write
    @book_body << "<h1 id=\"chap#{@index.to_s}\">#{@chapter_title_plain}</h1>"
    @book_body << @chapter_content
    @toc << "<a href=\"#chap#{@index.to_s}\">#{@chapter_title_plain}</a><br>"
    @index += 1
    #next
    @next_chapter = if doc.css('div.entry-content p a').last.content.to_s.include?("Next")
    doc.css('div.entry-content p a').last['href']
    else
      false
    end
	end

	$stderr.puts "Writing Book..."

	puts @toc
	puts @book_body
end	

story.each{ |key, val| if options.include?(key) 
	write_story(val)
	end
}
