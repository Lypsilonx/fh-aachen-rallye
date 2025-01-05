#import "@preview/tiaoma:0.2.1"
#import "@preview/suiji:0.3.0"

#set page(margin: 0pt)

#let fharCode(id, scale) = {
  box(
    stroke: (thickness: 1em * scale, paint: orange),
    radius: 2em * scale,
    inset: 2em * scale,
  )[
    #tiaoma.qrcode(
      "FHAR-" + id,
      options: (
        scale: 8.0,
        fg-color: blue,
        output-options: (
          barcode-dotty-mode: true
        ),
        dot-size: 1.2,
      )
    )

    #place(
      bottom + center,
      dy: 2.8em * scale,
    )[
    #box(
      fill: white,
      width: 90%,
      inset: 0.25em * scale,
    )[
        #text(
          font: "Futura",
          weight: 700,
          size: 1.5em * scale,
        )[
          FHAR-#id
        ]
      ]
    ]
  ]
}

#let random_code(seed) = {
  // random 8 digit code (numbers and letters)
  let code = ""
  let rng = suiji.gen-rng-f(seed)
  let a = ()
  (rng, a) = suiji.integers-f(rng, high: 35, size: 8)
  for r in a {
    if (r < 10) {
      r = str(r)
    } else {
      r = str.from-unicode(r + 55)
    }
    code = code + r
  }

  return code
}

#let random_codes(n, seed) = {
  let codes = ()
  for i in range(n) {
    codes = codes + (random_code(seed + i),)
  }
  return codes
}

#let amount_big = 6
#let amount_small = 24
#let codes = random_codes(amount_big + amount_small, 52)

#grid(
  columns: (100% / 6,) * 6,
  rows: (12.5%,) * int((amount_big * 4 + amount_small) / 6),
  ..codes.enumerate()
  .map(
    item => {
      let i = item.at(0)
      let id = item.at(1)

      let is_big = i < amount_big

      grid.cell(
        inset: if (is_big) {1em} else {0.75em},
        rowspan: if (is_big) {2} else {1},
        colspan: if (is_big) {2} else {1},
      )[
        #fharCode(id, if (is_big) {0.7} else {0.3})
      ]
    }
  )
)