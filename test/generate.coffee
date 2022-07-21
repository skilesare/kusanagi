assert = require "assert"
{parse} = require "../source/kusanagi"
generate = require "../source/generate"

{readFileSync} = require "fs"

describe "generate", ->
  it "should generate Motoko code from source", ->
    ast = parse(readFileSync("./test/examples/Basic.ku", "utf8"))
    assert ast

    assert.equal generate(ast), """
      import State "State"

      module {
        public class Grid (state:State.State)  {
          let grid = state;
          let n = grid.size();
          public func size ()  : Nat {
            n
          };
          func nextCell (i:Nat, j:Nat)  : State.Cell {
            let l:Nat = living(i, j);
            if (get(i, j)) {
              l == 2 or l == 3
            }
            else {
              l == 3
            }
          };
          func next (dst:Grid)  {
            for (i in grid.keys()) {
              let cool = true;
              for (j in grid[i].keys()) {
                let yo = "wat";
                dst.set(i, j, nextCell(i, j))
              }
            }
          }
        }
      }
    """
