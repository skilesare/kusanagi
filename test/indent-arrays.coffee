parser = require "../source/test"

{writeFileSync} = require "fs"

describe 'Arrays', ->
  it "arrays", ->
    result = parser.parse """
      []
      [     ]
      [a]
    """

    assert.deepEqual result, [
      []
      []
      ["a"]
    ]

  it "should parse array sequences of elements", ->
    assert parser.parse """
      [a, b, c]
    """

  it "should parse nested arrays", ->
    assert parser.parse """
      [[[[]]]]
      [[[[a]]]]
    """

  it "should parse nested arrays with spacing", ->
    assert parser.parse """
      [ [   [   [ ]   ]  ]        ]
    """

  it "should parse list indented at first position", ->
    result = parser.parse """
      [
        a
        b
        c
      ]
    """

    assert.deepEqual result, [["a", "b", "c"]]

  it "should handle indented expressions", ->
    result = parser.parse """
      [
        a
        [b, [], [d]]
        c
      ]
    """

    assert.deepEqual result[0], ["a", ["b", [], ["d"]], "c"]