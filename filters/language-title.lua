-- The analysis code is shared; only the page title changes with the language.
function Meta(meta)
  if pandoc.utils.stringify(meta.lang) == "ja" and meta["title-ja"] then
    meta.title = meta["title-ja"]
  end
  return meta
end
