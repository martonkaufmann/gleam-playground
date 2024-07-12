import envoy
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/order.{type Order}
import gleam/regex.{type Match}
import gleam/result
import gleam/set
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

pub type Color {
  Black
  Brown
  Red
  Orange
  Yellow
  Green
  Blue
  Violet
  Grey
  White
}

pub fn code(color: Color) -> Int {
  case color {
    Black -> 0
    Brown -> 1
    Red -> 2
    Orange -> 3
    Yellow -> 4
    Green -> 5
    Blue -> 6
    Violet -> 7
    Grey -> 8
    White -> 9
  }
}

pub fn colors() -> List(Color) {
  [Black, Brown, Red, Orange, Yellow, Green, Blue, Violet, Grey, White]
}

pub type Robot {
  Robot(direction: Direction, position: Position)
}

pub type Direction {
  North
  East
  South
  West
}

pub type Position {
  Position(x: Int, y: Int)
}

pub fn create(direction: Direction, position: Position) -> Robot {
  Robot(direction: direction, position: position)
}

pub fn direction_movement(
  intruction: String,
  direction: Direction,
) -> #(Direction, Int, Int) {
  case intruction, direction {
    "L", West | "R", East -> #(South, 0, 0)
    "L", South | "R", North -> #(East, 0, 0)
    "L", North | "R", South -> #(West, 0, 0)
    "L", East | "R", West -> #(North, 0, 0)
    _, East -> #(direction, 1, 0)
    _, West -> #(direction, -1, 0)
    _, South -> #(direction, 0, -1)
    _, North -> #(direction, 0, 1)
  }
}

pub fn move(
  direction: Direction,
  position: Position,
  instructions: String,
) -> Robot {
  case string.first(instructions) {
    Ok(x) -> {
      let #(direction, x_move, y_move) = direction_movement(x, direction)
      move(
        direction,
        Position(x: position.x + x_move, y: position.y + y_move),
        string.slice(instructions, 1, string.length(instructions)),
      )
    }
    Error(Nil) -> {
      create(direction, position)
    }
  }
}

pub fn wines_of_color(wines: List(Wine), color: WineColor) -> List(Wine) {
  wines |> list.filter(fn(wine) { wine.color == color })
}

pub fn wines_from_country(wines: List(Wine), country: String) -> List(Wine) {
  wines |> list.filter(fn(wine) { wine.country == country })
}

// Please define the required labelled arguments for this function
pub fn filter(
  wines: List(Wine),
  color color: WineColor,
  country country: String,
) -> List(Wine) {
  wines
  |> wines_of_color(color)
  |> wines_from_country(country)
}

pub type Wine {
  Wine(name: String, year: Int, country: String, color: WineColor)
}

pub type WineColor {
  Rose
}

fn int_to_text(int: Int) -> String {
  case int {
    1 -> "one"
    2 -> "two"
    3 -> "three"
    4 -> "four"
    5 -> "five"
    6 -> "six"
    7 -> "seven"
    8 -> "eight"
    9 -> "nine"
    10 -> "ten"
    _ -> int.to_string(int)
  }
}

pub fn recite(
  start_bottles start_bottles: Int,
  take_down take_down: Int,
) -> String {
  let verse =
    string.repeat(
      string.capitalise(int_to_text(start_bottles))
        <> case start_bottles {
        1 -> " green bottle hanging on the wall,\n"
        _ -> " green bottles hanging on the wall,\n"
      },
      2,
    )
    <> "And if one green bottle should accidentally fall,\n"
    <> case start_bottles - 1 {
      0 -> "There'll be no green bottles hanging on the wall."
      1 -> "There'll be one green bottle hanging on the wall."
      _ ->
        "There'll be "
        <> int_to_text(start_bottles - 1)
        <> " green bottles hanging on the wall."
    }

  case take_down - 1 {
    0 -> verse
    _ -> verse <> "\n\n" <> recite(start_bottles - 1, take_down - 1)
  }
}

pub fn first_letter(name: String) -> String {
  result.unwrap(name |> string.trim |> string.first, "")
}

pub fn initial(name: String) {
  name |> first_letter |> string.capitalise |> string.append(".")
}

pub fn initials(full_name: String) {
  full_name |> string.split(" ") |> list.map(initial) |> string.join(" ")
}

pub fn main() {
  let phrase = "the quick brown fox jumps over the lazy dog"
  let t =
    phrase
    |> string.replace("-", "")
    |> string.replace(" ", "")
    |> string.lowercase
    |> fn(x) { x == x |> string.split("") |> list.unique |> string.join("") }
  //io.debug(sum([3, 0], 4))
  //  io.debug(list.concat([[1, 2, 3, 6], [4, 5, 6]]))
  //io.debug(t)

  let str =
    "\\left(\\begin{array}{cc} \\frac{1}{3} & x\\\\ \\mathrm{e}^{x} &... x^2 \\end{array}\\right)"
    |> string.split("")

  let res2 =
    str
    |> list.fold("", fn(acc, x) {
      case x {
        "(" | "[" | "{" -> acc <> x
        ")" | "]" | "}" -> {
          case string.last(acc) {
            Ok("(") if x == ")" -> string.drop_right(acc, 1)
            Ok("[") if x == "]" -> string.drop_right(acc, 1)
            Ok("{") if x == "}" -> string.drop_right(acc, 1)
            _ -> acc <> x
          }
        }
        _ -> acc
      }
    })

  //  io.debug(str)
  //io.debug(res2)
  //  let s = "LAAARRRAAL"
  //    io.println(string.slice(s, 1, string.length(s)))
  //    io.debug(move(East, Position(x: 2, y: -7), "RRAAAAALA"))

  let d = list.group(string.split("abcb", ""), fn(x) { x })
  let dd = list.group(string.split("dsa", ""), fn(x) { x })
  //  io.debug(d)
  //io.debug(dd)
  // io.debug(d == dd)

  let word = "dsaad"
  let candidates = ["dsa", "sad", "ads", "dsaad"]

  let word_lower = word |> string.lowercase
  let word_dict = str_to_dict(word_lower)
  list.filter(candidates, fn(x) {
    case string.lowercase(x) {
      y if y == word_lower -> False
      y -> str_to_dict(y) == word_dict
    }
  })

  // io.debug(recite(10, 5))

  //   io.debug(split_line("[INFO] Start.<*>[INFO] Processing...<~~~>[INFO] Success."))

  io.debug(tag_with_user_name("[INFO] New log in for User __JOHNNY__"))
}

pub fn str_to_dict(str: String) -> Dict(String, List(String)) {
  str |> string.split("") |> list.group(fn(x) { x })
}

pub fn is_valid_line(line: String) -> Bool {
  let assert Ok(re) = regex.from_string("^\\[(DEBUG|INFO|WARNING|ERROR)\\]")

  regex.check(re, line)
}

pub fn split_line(line: String) -> List(String) {
  let assert Ok(re) =
    regex.from_string(
      "(\\[(?:DEBUG|INFO|WARNING|ERROR)\\]\\s.*?)(?:\\<[*~=-]*\\>|$)",
    )
  regex.split(re, line) |> list.filter(fn(x) { x != "" })
}

pub fn tag_with_user_name(line: String) -> String {
  let assert Ok(re) = regex.from_string("User(?:\\s|\\t|\\n)+(.*?)(?:\\s|$)")

  case regex.split(re, line) {
    [_, user_name, _] -> "[USER] " <> user_name <> " " <> line
    _ -> line
  }
}

pub type City {
  City(name: String, temperature: Temperature)
}

pub type Temperature {
  Celsius(Float)
  Fahrenheit(Float)
}

pub fn fahrenheit_to_celsius(f: Float) -> Float {
  { f -. 32.0 } /. 1.8
}

pub fn compare_temperature(left: Temperature, right: Temperature) -> Order {
  case left, right {
    Fahrenheit(left), Celsius(right) ->
      float.compare(fahrenheit_to_celsius(left), right)
    Celsius(left), Fahrenheit(right) ->
      float.compare(left, fahrenheit_to_celsius(right))
    Fahrenheit(left), Fahrenheit(right) | Celsius(left), Celsius(right) ->
      float.compare(left, right)
  }
}

pub fn sort_cities_by_temperature(cities: List(City)) -> List(City) {
  list.sort(cities, fn(a, b) {
    compare_temperature(a.temperature, b.temperature)
  })
}
