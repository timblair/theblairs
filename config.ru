$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

use Rack::Static, :urls => ["/css", "/images", "/js"], :root => "public"

require 'theblairs'
run TheBlairs::Wedding
