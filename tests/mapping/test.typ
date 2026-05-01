#import "/lib.typ": arno-pro-optical-font

#assert.eq(arno-pro-optical-font(8.5pt), "Arno Pro Caption")
#assert.eq(arno-pro-optical-font(8.6pt), "Arno Pro SmText")
#assert.eq(arno-pro-optical-font(10.9pt), "Arno Pro SmText")
#assert.eq(arno-pro-optical-font(11pt), "Arno Pro")
#assert.eq(arno-pro-optical-font(14pt), "Arno Pro")
#assert.eq(arno-pro-optical-font(14.1pt), "Arno Pro Subhead")
#assert.eq(arno-pro-optical-font(21.5pt), "Arno Pro Subhead")
#assert.eq(arno-pro-optical-font(21.6pt), "Arno Pro Display")

#assert.eq(
  arno-pro-optical-font(10pt, weight: "semibold"),
  "Arno Pro Smbd SmText",
)

#assert.eq(
  arno-pro-optical-font(10pt, font: "Arno Pro Smbd", weight: "regular"),
  "Arno Pro Smbd SmText",
)

Mapping assertions passed.

