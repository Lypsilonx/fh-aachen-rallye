#import "@preview/plotst:0.2.0": *

#set page(margin: (top: 4em, bottom: 4em, left: 1em, right: 3em), width: 512pt, height: 256pt)

#let resolution = 100
// #let signal_strengths = (
//   (1, 1),
//   (3, 0.5),
//   (10, 0.2)
// )
// #let signal_strengths = (
//   (2, 1),
//   (5, 0.1),
//   (8, 0.2)
// )
// #let signal_strengths = (
//   (0.5, 1),
//   (2, 0.3),
//   (4, 0.2)
// )
#let signal_strengths = (
  (1, 1),
  (4, 0.4),
  (9, 0.2)
)

#let data = range(resolution).map(
  (i) => {
    let x = calc.pi * 2 / resolution * i
    let y = 0
    for (freq, strength) in signal_strengths {
      y += strength * calc.sin(x * freq)
    }

    return (x, y)
  }
)

#graph_plot(
  plot(
    data: data,
    axes: (
      axis(
        min: 0,
        max: calc.pi * 2,
        step: calc.pi / 2,
        helper_lines: true,
        values: ("0", "1/2π", "π", "3/2π"),
        stroke: rgb(0, 0, 0, 0),
      ),
      axis(
        min: -1,
        max: 1,
        step: 1,
        location: "left",
        helper_lines: true,
        helper_line_style: "solid",
        helper_line_color: black,
      ),
    ),
  ),
  (100%, 100%),
  rounding: 30%,
  markings: none,
  caption: none,
)

#graph_plot(
  plot(
    data: signal_strengths.map(
      (datapoint) => {
        let (freq, strength) = datapoint
        return (
          (freq - 0.001, 0),
          (freq, strength),
          (freq + 0.001, 0),
        )
      }
    ).fold((), (a, b) => a + b),
    axes: (
      axis(
        min: 0,
        max: 10,
        step: 1,
        marking_length: 0pt,
      ),
      axis(
        min: 0,
        max: 1,
        step: 0.25,
        location: "left",
        helper_lines: false,
      ),
    ),
  ),
  (100%, 100%),
  markings: none,
  caption: none,
)