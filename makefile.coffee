###
Installation of CoffeeScript
$ npm install -g coffee-script

Usage
$ coffee makefile.coffee

Function
1. Detect change of source file.
2. Compile CoffeeScript to JavaScript.
3. Run test.
###

fs = require 'fs'
path = require 'path'
coffee = require 'coffee-script'
uglifyjs = require 'uglify-js'
jsp = uglifyjs.parser
pro = uglifyjs.uglify
{ spawn } = require 'child_process'
{ Junc } = require 'junc'

requested = false

startWatch = ->
  for dir in ['src', 'test']
    fs.watch dir, onChange

onChange = (event, filename)->
  unless requested
    requested = true
    setTimeout (->
      requested = false
      startCompile()
    ), 1000

timeStamp = ->
  date = new Date()
  "#{ padLeft date.getHours() }:#{ padLeft date.getMinutes() }:#{ padLeft date.getSeconds() }"

padLeft = (num, length = 2, pad = '0')->
  str = num.toString 10
  while str.length < length
    str = pad + str
  str

startCompile = ->
  Junc.serial(
    Junc.func(->
      console.log "#{timeStamp()} Start compiling ..."
      @next()
    )
    Junc.func(->
      fs.readFile 'src/junc.coffee', 'utf8', @next
    )
    Junc.func((err, code)->
      @global.node = coffee.compile code.replace(
        /#if BROWSER([\s\S]*?)(#else[\s\S]*?)?#endif/g,
        (matched, $1, $2, offset, source)->
          if $2? then $2 else ''
      )
      @global.browser = coffee.compile code.replace(
        /#if BROWSER([\s\S]*?)(#else[\s\S]*?)?#endif/g,
        (matched, $1, $2, offset, source)->
          if $1? then $1 else ''
      )
      @next()
    )
    Junc.parallel(
      Junc.func(->
        fs.writeFile "lib/node/junc.js", @global.node, @next
      )
      Junc.func(->
        fs.writeFile "lib/browser/junc.js", @global.browser, @next
      )
      Junc.func(->
        ast = jsp.parse @global.browser
        ast = pro.ast_mangle ast
        ast = pro.ast_squeeze ast
        uglified = pro.gen_code ast
        fs.writeFile "lib/browser/junc.min.js", uglified, @next
      )
    )
    Junc.func(->
      console.log "#{ timeStamp() } Complete compiling!"
      @next()
    )
  )
  .complete(test)
  .start()

test = ->
  console.log "#{timeStamp()} Start testing ..."
  nodeunit = spawn 'nodeunit', ['test']
  nodeunit.stderr.setEncoding 'utf8'
  nodeunit.stderr.on 'data', (data)->
    console.log data.replace(/\s*$/, '')
  nodeunit.stdout.setEncoding 'utf8'
  nodeunit.stdout.on 'data', (data)->
    console.log data.replace(/\s*$/, '')
  nodeunit.on 'exit', (code)->
    console.log "#{timeStamp()} Complete testing!"

startWatch()
startCompile()
