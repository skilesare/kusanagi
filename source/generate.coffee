require "@danielx/hera/register"

fs = require "fs"

{parse} = require "./motoko"

indentation = "  "

generate = (node, indent="") ->
  gen = (item) ->
    generate(item, indent)
  genNested = (item) ->
    generate(item, indent + indentation)

  if typeof node is "string"
    return node

  if Array.isArray node
    return node.map gen
    .join("")

  if node is undefined or node is null
    return

  return switch node.type
    when "program"
      {imports, declarations} = node

      code = []

      if imports.length
        code.push imports.map(([source, pat]) ->
          "import #{pat} #{source}"
        ).join(";\n")

        if declarations.length
          code.push "\n\n"

      if declarations.length
        code.push declarations.map(gen).join(";\n")

      code.join("")

    when "actor"
      {type, id, body} = node

      code = ["actor"]

      if id
        code.push " ", id

      code.push " ", genNested(body)
      code.join("")

    when "block"
      {decs} = node

      if decs.length
        code = decs.map(genNested)

        "{\n#{indent}" + code.join(";\n#{indent}") + "\n#{indent.slice(0, -2)}}"
      else
        "{}"

    when "dec"
      {vis, stab, dec} = node

      [vis, stab, gen(dec)].filter (x) -> !!x
      .join(" ")

    when "let"
      {pat, exp} = node

      "let #{generate(pat)} = #{generate(exp)}"

    when "var"
      {id, exp} = node

      "var #{id} = #{generate(exp)}"

    when "exppost"
      {base, rest} = node

      "#{base}#{rest.map(gen).join("")}"

    when "projection"
      ".#{node.id}"

    when "application"
      generate(node.fnArgs)

    when "await"
      "await #{generate(node.exp)}"

    when "expbin"
      {exps} = node
      i = 1

      code = [generate(exps[0])]

      while i < exps.length
        code.push exps[i], generate(exps[i+1])
        i += 2

      code.join(" ")

    when "binassign"
      {base, op, exp} = node
      "#{base} #{op} #{generate(exp)}"

    when "func"
      {id, pat, body, shared, typeSuffix} = node

      ["#{shared}func", id, gen(pat), typeSuffix, gen(body)]
      .join(" ")

    when "if"
      {exp, condition} = node
      "if #{gen(condition)} #{gen(exp)}"

    when "parens"
      ["(", node.exps.map(gen).join(", "), ")"].join("")

    else
      "<UNKNOWN #{JSON.stringify(node)} >"

ast = parse(fs.readFileSync("./test/examples/Alarm.mo", "utf8"))
console.log(JSON.stringify(ast, null, 2))
console.log(generate(ast))
