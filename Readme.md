# Instascraper

This library provides a basic api to instapaper bookmarks for free by scraping the page

n.b. this is a work in progress, you probably shouldn't use it.

    gem install instascraper
    
    require 'instascraper'
    
    i = Instascraper.new('username', 'password')
    
    # load unread bookmarks
    bookmarks = i.bookmarks
    
    bookmarks.each do |b|
      puts b.link
      puts b.title
    end
    
    # folder support
    folder_bookmarks = i.bookmarks('folder name')
    

## Development

Significantly modified from the original [Instascraper](http://github.com/andrew/instascraper).
