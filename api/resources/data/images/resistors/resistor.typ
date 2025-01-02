#set page(width: 256pt, height: 128pt, margin: 0pt)

#let brown = rgb("#a5412a")
#let violet = rgb("#8a2be2")
#let gold = rgb("#a09137")

#let num_to_color(num) = {
  if (num < 0) {
    num = -num - 1

    let colors = (gold, silver)
    return colors.at(num)
  }

  let colors = (black, brown, red, orange, yellow, green, blue, violet, gray, white)
  return colors.at(num)
}

#let get_tolerance_color(tolerance) = {
  let tollerances = (
    "10": silver,
    "5": gold,
    "1": brown,
    "2": red,
    "0.5": green,
    "0.25": blue,
    "0.1": violet,
    "0.05": gray
  )

  if (not tollerances.keys().contains(str(tolerance))) {
    return none
  }

  return tollerances.at(str(tolerance))
}

#let get_resistor(ohm, tollerance) = {
  let zeros = 0;

  while (calc.rem(ohm, 1) != 0 and zeros > -2 and ohm < 10) {
    ohm *= 10
    zeros -= 1
  }

  let chars = str(ohm - calc.rem(ohm, 1)).split("").filter(c => c != "")

  // trim trailing zeros
  while(chars.len() > 2) {
    chars = chars.slice(0, -1)
    zeros += 1
  }

  if (chars.len() < 2) {
    chars.insert(0, "0")
  }

  let colors = chars.map(c => int(c))
  .map(c => num_to_color(c));

  // add multiplier
  colors.push(num_to_color(zeros))

  // add tollerance
  colors.push(get_tolerance_color(tollerance))

  return colors;
}

#let color_code = get_resistor(420, 20);

#place(
  center + horizon,
  box(
    width: 256pt,
    height:8pt,
    fill: gray,
    stroke: (paint: black, thickness: 1pt)
  )
)

#place(
  center + horizon,
  box(
    width: 128pt,
    height: 40pt,
    fill: rgb("#dcc083"),
    stroke: (paint: black, thickness: 1pt)
  )[
    #grid(
      columns: color_code.slice(1,-1).len() + 1,
      rows: 1,
      column-gutter: 24pt,
      ..color_code.slice(1,-1).map(
        color =>
          box(
            height: 100% - 1pt,
            width: 8pt,
            fill: color,
          )
      )
    )
  ]
)

#place(
  dx: -64pt,
  center + horizon,
  box(
    width: 32pt,
    height: 56pt,
    fill: rgb("#dcc083"),
    stroke: (paint: black, thickness: 1pt)
  )[
    #box(
      height: 100% - 1pt,
      width: 8pt,
      fill: color_code.at(0)
    )
  ]
)

#place(
  dx: 64pt,
  center + horizon,
  box(
    width: 32pt,
    height: 56pt,
    fill: rgb("#dcc083"),
    stroke: (paint: black, thickness: 1pt)
  )[
    #box(
      height: 100% - 1pt,
      width: 8pt,
      fill: color_code.at(-1)
    )
  ]
)