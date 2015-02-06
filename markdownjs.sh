#!/bin/sh
#
# create an HTML skeleton with a javascript call to convert markdown content to HTML
# the markdown filename is expected in the PATH_TRANSLATED environment variabled which is set by
# apache for a CGI call. For nginx, a bit of extra config is needed to properly set PATH_TRANSLATED

cat << EOF
Content-type: text/html

<html>
	<head>
		<meta charset="utf-8"/>
		<title>${SCRIPT_NAME}</title>
		<script src="//code.jquery.com/jquery-1.11.0.min.js"></script>
		<script src="https://rawgit.com/chjj/marked/master/marked.min.js"></script>
		<style>
			table, th, td { border: 1px solid black; }
			table { border-collapse: collapse; }
			td { padding-right: 15px; }
		</style>
	</head>

	<body>
		<div id="content">$(cat $PATH_TRANSLATED)</div>
		<script>
			var content = document.getElementById('content');
			content.innerHTML = marked(content.innerHTML);
		</script>
	</body>
</html>
EOF
