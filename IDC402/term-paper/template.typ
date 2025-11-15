#let project(title: "", authors: (), body) = {
  set document(author: authors, title: title)
  set page(margin:(x: 1.5cm, y: 1.5cm))
  set text(font: "STIX Two Text", lang: "en", size: 12pt)
  show math.equation: set text(weight: 400)
  show figure.caption : set text(size: 8pt, style: "italic")

  show title : smallcaps
  align(center)[#text(size: 17pt, weight: "bold")[#underline(title)]]
  v(25pt)

  show: rest => columns(2, rest)

  let heading-numbering = "I.A.1"
  set heading(numbering: heading-numbering)
  show heading: it => context {
    let loc = here()
    let levels = counter(heading).at(loc)
    if it.level == 1 {
        let is-special = it.body in ([Acknowledgement], [Bibliography], [Credits])
      set text(if is-special { 11pt } else { 13pt })
      set align(center)
      show: smallcaps
      v(27pt, weak: true)
      if it.numbering != none and not is-special {
        numbering(heading-numbering.split(".").at(it.level - 1), levels.last())
        [.]
        h(5pt, weak: true)
      }
      it.body
      v(13.5pt, weak: true)
    } else if it.level == 2 {
      set text(12pt)
      set par(first-line-indent: 0pt)
      v(20pt, weak: true)
      if it.numbering != none {
        numbering(heading-numbering.split(".").at(it.level - 1), levels.last())
        [.]
        h(5pt, weak: true)
      }
      it.body
      v(10pt, weak: true)
    } else {
      set text(10pt)
      if it.level == 3 {
        numbering(heading-numbering.split(".").at(it.level - 1), levels.last())
        [. ]
        h(5pt, weak: true)
      }
      text(style: "italic")[#it.body]
    }
  }
  set par(justify: true)
  body
}
