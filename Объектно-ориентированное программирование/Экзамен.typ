#import "@preview/zebraw:0.5.5": *
#show: zebraw.with(numbering: true, numbering-separator: true, lang: false)

#page(
  numbering: none,
  fill: gradient.linear(
    white,
    color.olive.lighten(50%),
    angle: 45deg,
  ),
)[
  #set text(size: 16pt)

  #place(center + horizon)[
    #par(
      text(
        size: 30pt,
        hyphenate: false,
        weight: "bold",
        "Объектно-ориентированное программирование",
      ),
    )
    #v(1em, weak: true)
    *Подготовка к экзамену* \
    4 семестр
  ]

  #place(center + bottom)[2025 г.]
]

#set text(lang: "ru", size: 14pt)
#set raw(lang: "cpp")
#set page(margin: 10mm, numbering: "1")
#set par(
  justify: true,
  linebreaks: "optimized",
  justification-limits: (
    tracking: (min: -0.01em, max: 0.01em),
  ),
)
#set terms(separator: [ --- ], hanging-indent: 0pt)
#set heading(numbering: "1.")
#show heading.where(level: 4): set heading(numbering: none)
#show terms.item: it => {
  rect(width: 100%, radius: 7pt, stroke: gradient.linear(..color.map.crest), fill: color.aqua.lighten(80%))[#it]
}
#show table.cell.where(y: 0): strong
#show table.cell.where(y: 0): set align(horizon)
#show table: set par(justify: false)

#set enum(numbering: "1)", full: true)
#set list(marker: ([---], sym.bullet))


#[
  #show outline: it => {
    show heading: it => align(center, it)
    it
  }
  #show outline.entry.where(level: 1): it => {
    v(1.1em, weak: true)
    set text(weight: "bold")
    it
  }
  #outline(depth: 2, title: "СОДЕРЖАНИЕ")
  #pagebreak(weak: true)
]

#show heading.where(level: 1): set text(fill: lime.darken(30%))

#for i in range(1, 33) {
  let num = if i < 10 { "0" + str(i) } else { str(i) }

  include num + ".typ"
  pagebreak(weak: true)
}
