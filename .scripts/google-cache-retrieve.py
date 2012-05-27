#!/usr/bin/python
import urllib
import urllib2
import re
import socket
import os
import time
import random

socket.setdefaulttimeout(30)
#adjust the site here
search_site="blog.skindirect.com"
search_term="site:" + search_site
def main():
    headers = {'User-Agent': 'Mozilla/5.0 (X11; U; Linux i686 (x86_64); en-US; rv:1.8.1.4) Gecko/20070515 Firefox/2.0.0.4'}
    url = "http://www.google.com/search?q="+search_term

    regex_cache = re.compile(r'<a href="([^"]*)"[^>]*>Cached</a>')
    regex_next = re.compile('<a href="([^"]*)"[^>]*><span[^>]*>[^<]*</span><span[^>]*>Next</span></a>')

    #this is the directory we will save files to
    try:
        os.mkdir(search_site)
    except:
        pass
    counter = 0
    pagenum = 0
    more = True
    while(more):
        pagenum += 1
        print "PAGE "+str(pagenum)+": "+url
        req = urllib2.Request(url, None, headers)
        page = urllib2.urlopen(req).read()
        matches = regex_cache.findall(page)
        print matches
        for match in matches:
            counter+=1
            if not match.startswith("http"):
                match = "http:" + match
            tmp_req = urllib2.Request(match.replace('&amp;','&'), None, headers)
            tmp_page = urllib2.urlopen(tmp_req).read()
            print counter,": "+match
            f = open(search_site + "/" + str(counter)+'.html','w')
            f.write(tmp_page)
            f.close()
            #comment out the code below if you expect to crawl less than 50 pages
            random_interval=random.randrange(10,30,1)
            print "sleeping for: " + str(random_interval) + " seconds"
            time.sleep(random_interval)
        #now check if there is more pages
        match = regex_next.search(page)
        if match == None:
            more = False
        else:
            url = "http://www.google.com"+match.group(1).replace('&amp;','&')
 
if __name__=="__main__":
    main()
 
# vim: ai ts=4 sts=4 et sw=4
