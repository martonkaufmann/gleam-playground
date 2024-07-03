import envoy
import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/regex
import gleam/string


fn is_triangle(a: Float, b: Float, c: Float) -> Bool {
  let max = float.max(a, b) |> float.max(c)

  { a *. b *. c } != 0.0 && max <. a +. b +. c -. max
}

pub fn equilateral(a: Float, b: Float, c: Float) -> Bool {
  case is_triangle(a, b, c) {
    True -> a == b && a == c
    False -> False
  }
}

pub type Player {
  Player(name: Option(String), level: Int, health: Int, mana: Option(Int))
}

pub fn revive(player: Player) -> Option(Player) {
  case player.health {
    0 if player.level >= 10 ->
      option.Some(Player(..player, health: 100, mana: option.Some(100)))
    0 if player.level < 10 -> option.Some(Player(..player, health: 100))
    _ -> option.None
  }
}

pub fn cast_spell(player: Player, cost: Int) -> #(Player, Int) {
  let damage = cost * 2

  let #(health, mana) = case player.mana {
    option.None -> #(player.health - damage, option.None)
    option.Some(mana) if mana < cost -> #(player.health, option.Some(mana))
    option.Some(mana) -> #(player.health, option.Some(mana - cost))
  }

  #(
    Player(..player, health: int.clamp(health, 0, player.health), mana: mana),
    damage,
  )
}

pub type TreasureChest(a) {
  TreasureChest(password: String, treasure: a)
}

pub type UnlockResult(a) {
  WrongPassword
  Unlocked(a)
}

pub fn get_treasure(
  chest: TreasureChest(treasure),
  password: String,
) -> UnlockResult(treasure) {
  case chest {
    c if c.password == password -> Unlocked(chest.treasure)
    _ -> WrongPassword
  }
}

pub fn two_fer(name: Option(String)) -> String {
  case name {
    option.Some(name) -> "One for " <> name <> ", one for me."
    option.None -> "One for you, one for me."
  }
}

pub fn sum_old(factors factors: List(Int), limit limit: Int) -> Int {
    // todo use filter
  list.fold(factors, 0, fn(acc, factor) {
    acc
    + {
      case factor {
        0 -> 0
        _x if limit < factor -> 0
        _ ->
          list.range(factor, limit - 1)
                    // todo use filter
          |> list.fold(0, fn(acc, x) {
            case x % factor {
              0 -> acc + x
              _ -> acc
            }
          })
      }
    }
  })
}

pub fn sum(factors factors: List(Int), limit limit: Int) -> Int {
    list.filter(factors, fn(factor) { factor != 0 && limit >= factor })
    |> list.map(fn(factor) { 
        list.range(factor, limit - 1)
        |> list.filter(fn(x) { x % factor == 0 })
    })
    |> list.concat
    |> list.unique
    |> int.sum
}

pub fn main() {
  //  io.debug(list.range(3, 3))
  //   io.debug(list.range(4, -1))
  //   io.debug(0%3)
  //   io.debug(-1%3)
  //   io.debug(0 % 3)
  //   io.debug(int.max(0, -3))
    let phrase = "the quick brown fox jumps over the lazy dog"
    let t =   phrase
    |> string.replace("-", "")
    |> string.replace(" ", "")
    |> string.lowercase 
    |> fn(x) {
      x == x |> string.split("") |> list.unique |> string.join("")
    }
  io.debug(sum([3, 0], 4))
    io.debug(list.concat([[1, 2, 3, 6], [4, 5, 6]]))
    io.debug(t)
}
