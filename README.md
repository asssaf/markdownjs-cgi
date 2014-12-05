markdownjs-cgi
==============
CGI script and config for serving HTML for markdown files.

Markdown generation happens in the client side using javascript markdown library (marked).

A cgi shell script creates the HTML skeleton and javascript for the transformation.

A Dockerfile is included that builds a preconfigured nginx image which can be run with docker.


Running with docker
===================
The container runs nginx with a markdown handler for all paths ending in `.md`. All other files (besides htmls) are not accessible, so you can expose your source repository for the documentation without exposing all the source code or other sensitive files.

The container expects the files to be served to be mounted on `/www`.


```sh
$ docker run -d --name docs \
	-v ~/my_repo:/www/docs/my_repo \
	-p 127.0.0.1:5080:80 \
	markdownjs-cgi
```

Proxying the container from an external apache
----------------------------------------------
Once the container is up it is possible to proxy it from an external apache server using the following config:

        ProxyPreserveHost  On
        ProxyRequests      Off

        ProxyPass          /docs http://127.0.0.1:5080/docs
        ProxyPassReverse   /docs http://127.0.0.1:5080/docs

Standalone Config
=================

If you don't want to use the container you can use the following CGI config for serving the markdown files (versions for nginx and apache provided).

nginx config (+fcgiwrap)
------------------------
This config uses fcgiwrap (needs to be run separately) with a unix socket (`unix:/var/run/fcgiwrap.socket`).

Assuming that `markdownjs.sh` is installed in `/usr/lib/cgi-bin` and you want serve files under `/www`:

    location / {
        root   /www;
        index  index.html README.md;

        deny all;

        location ~ (\.html|/)$ {
            allow all;
        }
    }

    location ~ \.md$ {
        gzip off;
        root /www;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /usr/lib/cgi-bin/markdownjs.sh;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_script_name;
        fastcgi_pass unix:/var/run/fcgiwrap.socket;
    }


Apache
------
Assuming CGI is enabled and the `markdownjs.sh` script was dropped in the `cgi-bin` directory:

       [Directory /www]
               Order allow,deny
               Deny from all
               [FilesMatch "\.(html|md)$"]
                       Allow from all
               [/FilesMatch]
               [FilesMatch "^$"]
                       Allow from all
               [/FilesMatch]

               DirectoryIndex index.html README.md
               Action markdownjs /cgi-bin/markdownjs.sh
               AddHandler markdownjs .md
       [/Directory]



