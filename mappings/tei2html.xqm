xquery version '3.0' ;
module namespace synopsx.mappings.tei2html = 'synopsx.mappings.tei2html' ;

(:~
 : This module is a TEI to html function library for SynopsX
 :
 : @version 2.0 (Constantia edition)
 : @since 2015-02-17 
 : @author synopsx team
 :
 : This file is part of SynopsX.
 : created by AHN team (http://ahn.ens-lyon.fr)
 :
 : SynopsX is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 : SynopsX is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 : See the GNU General Public License for more details.
 : You should have received a copy of the GNU General Public License along 
 : with SynopsX. If not, see http://www.gnu.org/licenses/
 :)

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare default function namespace 'synopsx.mappings.tei2html' ;

(:~
 : this function 
 :)
declare function entry($node as node()*, $options as map(*)) as item()* {
 <div>
    { dispatch($node, $options) }
 </div>
};

(:~
 : this function dispatches the treatment of the XML document
 :)
declare function dispatch($node as node()*, $options as map(*)) as item()* {
  typeswitch($node)
    case text() return $node
    case element(tei:lb) return lb($node, $options)
    case element(tei:cb) return cb($node, $options)
    case element(tei:pb) return pb($node, $options)
    case element(tei:hi) return hi($node, $options)
    case element(tei:date) return getDate($node, $options)
    case element(tei:p) return p($node, $options)
    case element(tei:add) return add($node, $options)
    case element(tei:del) return del($node, $options)
    case element(tei:gap) return gap($node, $options)
    case element(tei:choice) return choice($node, $options)
    case element(tei:unclear) return unclear($node, $options)
    case element(tei:ex) return ex($node, $options)
    case element(tei:foreign) return foreign($node, $options)
    case element(tei:cell) return cell($node, $options)
    case element(tei:row) return row($node, $options)
    case element(tei:table) return table($node, $options)
    case element(tei:supplied) return supplied($node, $options)
    case element(tei:item) return synopsx.mappings.tei2html:item($node, $options)
    case element(tei:label) return label($node, $options)
    case element(tei:list) return list($node, $options)
    case element(tei:head) return head($node, $options)
    case element(tei:div) return div($node, $options)
    case element(tei:cit) return cit($node, $options)
    case element(tei:closer) return closer($node, $options)
    case element(tei:title) return title($node, $options)
    case element(tei:titlePart) return titlePart($node, $options)
    case element(tei:docEdition) return docEdition($node, $options)
    case element(tei:docImprint) return docImprint($node, $options)
    case element(tei:addrLine) return addrLine($node, $options)
    case element(tei:correspDesc) return correspDesc($node, $options)
    case element(tei:ref) return ref($node, $options)
    case element(tei:note) return note($node, $options)
    case element(tei:idno) return idno($node, $options)
    case element(tei:monogr) return getMonogr($node, $options)
    case element(tei:analytic) return getAnalytic($node, $options)
    case element(tei:persName) return getName($node, $options)
    case element(tei:listPerson) return listPerson($node, $options)
    case element(tei:person) return person($node, $options)
    case element(tei:author) return getResponsabilities($node, $options)
    case element(tei:edition) return getEdition($node, $options)
    case element(tei:editor) return getResponsabilities($node, $options)
    case element(tei:bibl) return biblItem($node, $options)
    case element(tei:biblStruct) return biblItem($node, $options)
    case element(tei:listBibl) return listBibl($node, $options)
    case element(tei:witness) return witness($node, $options)
    case element(tei:listWit) return listWit($node, $options)
    case element(tei:msDesc) return msDesc($node, $options)
    case element(tei:msItem) return passthru($node, $options)
    case element(tei:figure) return figure($node, $options)
    case element(tei:formula) return formula($node, $options)
    case element(tei:graphic) return graphic($node, $options)
    (: case element(tei:text) return synopsx.mappings.tei2html:text($node, $options) :)
    case element(tei:front) return front($node, $options)
    case element(tei:body) return passthru($node, $options)
    case element(tei:back) return passthru($node, $options)
    case element(tei:teiHeader) return teiHeader($node, $options)
    case element(tei:TEI) return passthru($node, $options)
    case element(tei:said) return said($node, $options)
    default return passthru($node, $options)
};

(:~
 : This function pass through child nodes (xsl:apply-templates)
 :)
declare function passthru($nodes as node(), $options as map(*)) as item()* {
  for $node in $nodes/node()
  return dispatch($node, $options)
};


(:~
 : ~:~:~:~:~:~:~:~:~
 : tei textstructure
 : ~:~:~:~:~:~:~:~:~
 :)

declare function teiHeader($node as element(tei:teiHeader)+, $options as map(*)) {
  (: getSourceDesc($node, $options), :)
  switch ($node)
  case ($node[ancestor::tei:TEI/tei:text[@type='correspondance']]) return correspDesc($node//tei:correspDesc, $options)
  case ($node[ancestor::tei:TEI/tei:text[@type='archives']]) return archivesList($node//tei:sourceDesc/tei:msDesc, $options)
  default return ()
};

(: declare function synopsx.mappings.tei2html:text($node as element(tei:text)+, $options as map(*)) {
  switch ($node)
  case ($node[@type='archives']) return 
    for $x in db:open('ampere', 'archives')/tei:TEI/tei:text[fn:ends-with(@decls, 'chem1')]
    return 
      for $text in $node/tei:group/tei:text
      return
        <table>{
          for $num in $text//tei:pb[fn:data(@n)]
          return 
            <tr>
              <td>{$num/fn:data(@n)}</td>
              <td>{passthru($num//following-sibling::tei:*, $options)}</td>
            </tr>
        }</table>
  default return passthru($node, $options)
}; :)

declare function div($node as element(tei:div)+, $options as map(*)) {
  <div>
    { if ($node/@xml:id) then attribute id { $node/@xml:id } else (),
    passthru($node, $options)}
  </div>
};

declare function front($node as element(tei:front)+, $options as map(*)) {
    <div class="front">{
        passthru($node, $options)
    }</div>
};

declare function head($node as element(tei:head)+, $options as map(*)) as element() {   
  <h4 class='head'>{ passthru($node, $options) }</h4>
   (: if ($node/parent::tei:div) then
    let $type := $node/parent::tei:div/@type
    let $level := if ($node/ancestor::div) then fn:count($node/ancestor::div) + 1 else 1
    return element { 'h' || $level } { passthru($node, $options) }
  else if ($node/parent::tei:figure) then
    if ($node/parent::tei:figure/parent::tei:p) then
      <strong>{ passthru($node, $options) }</strong>
    else <p><strong>{ passthru($node, $options) }</strong></p>
  else if ($node/parent::tei:list) then
    <strong>{ passthru($node, $options) }</strong>
  else if ($node/parent::tei:table) then
    <th>{ passthru($node, $options) }</th>
  else  passthru($node, $options):)
};

declare function p($node as element(tei:p)+, $options as map(*)) {
  switch ($node)
  case ($node[ancestor::tei:note]) return <p class='inline'>{ passthru($node, $options) }</p>
  case ($node[ancestor::tei:text[@type='publications' or @type='archives' or @type='correspondance']]) return 
    <p class="pundit-content" about="{fn:concat('http:ampere.dev.huma-num.fr/ampere/', getCorpus($node, $options), '/', getId($node, $options), '/')}">{ passthru($node, $options) }</p>
  default return passthru($node, $options) 
};

declare function list($node as element(tei:list)+, $options as map(*)) {
  switch ($node) 
  case ($node/@type='ordered' or $node[child::tei:item[@n]]) return <ol>{ passthru($node, $options) }</ol>
  case $node[child::tei:label] return <dl>{ passthru($node, $options) }</dl>
  default return <ul>{ passthru($node, $options) }</ul>
};

declare function synopsx.mappings.tei2html:item($node as element(tei:item)+, $options as map(*)) {
  switch ($node)
  case $node[parent::*/tei:label] return <dd>{ passthru($node, $options) }</dd>
  default return <li>{ passthru($node, $options) }</li>
};

declare function label($node as element(tei:label)+, $options as map(*)) {
  <dt>{ passthru($node, $options) }</dt>
};

declare function note($node as element(tei:note)+, $options as map(*)) {
  switch ($node)
  case ($node[parent::tei:biblStruct]) return <p class='noteBibl'><em>Note : </em> { passthru($node, $options) }</p>
  case ($node[ancestor::tei:back]) return 
    <div class="note">
      <sup>
        <a id='{$node/@xml:id}' href='{'#ref' || $node/@xml:id}'>{
          for $ref in $node/ancestor::tei:text//tei:ref[fn:substring-after(@target, '#') = $node/@xml:id]
          return if ($ref) then ($ref) else ()
        }</a>
      </sup>&#160;
      {passthru($node, $options)}
    </div>
  default return <div class='note'>{ passthru($node, $options) }</div>
};

declare function table($node as element(tei:table), $options as map(*)) {
  <table class="table">{ passthru($node, $options) }</table>
};

declare function row($node as element(tei:row), $options as map(*)) {
  <tr class="row">{ passthru($node, $options) }</tr>
};

declare function cell($node as element(tei:cell), $options as map(*)) {
  switch ($node)
  case ($node[@cols]) return <td class="cell" colspan='{ $node/@cols }'>{ passthru($node, $options) }</td>
  case ($node[@rows]) return <td class="cell" rowspan='{ $node/@rows }'>{ passthru($node, $options) }</td>
  default return <td class="cell">{ passthru($node, $options) }</td>
};

declare function formula($node as element(tei:formula), $options as map(*)) {
   $node/*
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei inline
 : ~:~:~:~:~:~:~:~:~
 :)
declare function cit($node as element(tei:cit)+, $options as map(*)) {
  switch ($node)
  case ($node[@xml:lang]) return fn:concat('« ', <blockquote class='quote'><em class='cit'>{ passthru($node, $options) }</em></blockquote>, ' »')
  default return ('« ', <blockquote class='quote'>{ passthru($node, $options) }</blockquote>, ' »')
};

declare function closer($node as element(tei:closer)+, $options as map(*)) {
  <p class='closer'>{ passthru($node, $options) }</p>
};

declare function hi($node as element(tei:hi)+, $options as map(*)) {
  switch ($node)
  case ($node[@rend='italic' or @rend='it']) return <em>{ passthru($node, $options) }</em> 
  case ($node[@rend='bold' or @rend='b']) return <strong>{ passthru($node, $options) }</strong>
  case ($node[@rend='superscript' or @rend='sup']) return <sup>{ passthru($node, $options) }</sup>
  case ($node[@rend='underscript' or @rend='sub']) return <sub>{ passthru($node, $options) }</sub>
  case ($node[@rend='underline' or @rend='u']) return <u>{ passthru($node, $options) }</u>
  case ($node[@rend='strikethrough']) return <del class="hi">{ passthru($node, $options) }</del>
  case ($node[@rend='caps' or @rend='uppercase']) return <span calss="uppercase">{ passthru($node, $options) }</span>
  case ($node[@rend='smallcaps' or @rend='sc']) return <span class="small-caps">{ passthru($node, $options) }</span>
  default return <span class="{$node/@rend}">{ passthru($node, $options) }</span>
};

(:~
 : @todo gérer les cas avec l'attribut @hand pour les archives
 :)
declare function add($node as element(tei:add)+, $options as map(*)) {
  <sup class='add'>{ passthru($node, $options) }</sup>
};

declare function del($node as element(tei:del)+, $options as map(*)) {
  switch ($node)
  case ($node[@type='illisible']) return <span class='del'>[illisible]</span>
  default return <del>{ passthru($node, $options) }</del>
};

declare function lb($node as element(tei:lb), $options as map(*)) {
    switch($node)
    case ($node[@rend='hyphen']) return ('-', <br/>)
    case ($node) return <br/>
    default return ()
};

declare function cb($node as element(tei:cb), $options as map(*)) {
    switch($node)
    case ($node[@rend='hyphen']) return ('-', <br/>)
    case ($node) return <br/> (: &#10548; :)
    default return ()
};

(:~
 : @todo: gérer les attributs @facs pour les archives
 : @todo: gérer les attributs @type='deplacement'
 :)
declare function pb($node as element(tei:pb), $options as map(*)) {
  switch ($node)
  case ($node[@ed and @n and @rend='hyphen']) return (<span class='pb'>-</span>, <br/>, <span class='pb'>{'{éd. ' || $node/@ed || ' : ' || $node/fn:data(@n) || '}-' }</span>)
  case ($node[@ed and @n]) return (<br/>, <span class='pb'>{'{éd. ' || $node/@ed || ' : ' || $node/fn:data(@n) || '}' }</span>)
  case ($node[@rend='hyphen' and @n]) return (<span class='pb'>-</span>, <br/>, <span class='pb'>{ '{' || $node/fn:data(@n) || '}-' }</span>)
  case ($node[@n]) return (<br/>, <span class='pb'>{'{' || $node/fn:data(@n) || '}' }</span>)
  default return ()
};

declare function getDate($node as element(tei:date), $options as map(*)) {
  switch ($node)
  case ($node[@cert='low']) return (passthru($node, $options), '&#160;?')
  default return passthru($node, $options)
};

declare function unclear($node as element(tei:unclear), $options as map(*)) {
  switch ($node)
  case ($node[child::text()]) return <mark>{ passthru($node, $options) }</mark>
  case ($node[fn:not(child::text())]) return <mark>[illisible]</mark>
  default return <span class='unclear'>{ passthru($node, $options) }</span>
};

declare function ex($node as element(tei:ex), $options as map(*)) {
  <em class='ex'>{ passthru($node, $options) }</em>
};

declare function foreign($node as element(tei:foreign), $options as map(*)) {
    switch ($node)
    case ($node[fn:not(@xml:lang = 'fr')]) return <em class='foreign'>{ passthru($node, $options) }</em> 
    case ($node[@xml:lang = 'fr']) return <span class='fr'>{ passthru($node, $options) }</span>
    default return <em class='foreign'>{ passthru($node, $options) }</em>
};

declare function said($node as element(tei:said), $options as map(*)) {
  <quote>{ passthru($node, $options) }</quote>
};

declare function figure($node as element(tei:figure), $options as map(*)) {
  <figure>{ passthru($node, $options) }</figure>
};

declare function supplied($node as element(tei:supplied), $options as map(*)) {
  <span class='supplied'>[{ passthru($node, $options) }]</span>
};

declare function title($node as element(tei:title), $options as map(*)) {
  switch ($node)
  case ($node[@type='publication']) return <em class="title"><a href='/ampere/publications/{$node/@ref}'>{ passthru($node, $options) }</a></em>
  case ($node[@type='ouvrages_mentionnes']) return <em class="title"><a href='/ampere/publications-citées/{$node/@ref}'>{ passthru($node, $options) }</a></em>
  default return <em class="title">{ passthru($node, $options) }</em>
};

declare function docEdition($node as element(tei:docEdition), $options as map(*)) {
  (<br/>, passthru($node, $options)  )
};

declare function docImprint($node as element (tei:docImprint), $options) {
  (<br/>, passthru($node, $options))
};

declare function titlePart($node as element(tei:titlePart), $options as map(*)) {
  (<br/>, passthru($node, $options)  )
};

declare function addrLine($node as element(tei:addrLine), $options as map(*)) {
  (<span class='address'>{ passthru($node, $options) }</span>, <br/>)
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei correspondance
 : ~:~:~:~:~:~:~:~:~
 :)
declare function correspDesc($node as element(tei:correspDesc)*, $options as map(*)) {
  for $correspDesc in $node
  return 
    <table class='corr'>
      <tr>
        <td><a href='/ampere/correspondance/{getIdItem(($node/ancestor::tei:TEI//tei:sourceDesc//tei:*[@xml:id])[1], $options)}'>{getIdItem(($node/ancestor::tei:TEI//tei:sourceDesc//tei:*[@xml:id])[1], $options)}</a></td>
        <td>Lettre de { getSenders($node/tei:correspAction[@type='sent'], $options) } à { getAdressees($node/tei:correspAction[@type='received'], $options) }</td>
        <td>{$node/tei:correspAction[@type='sent']/getDate(tei:date, $options)}</td>
      </tr>
    </table>
 };

declare function getSenders($node, $options as map(*)) {
  let $nbResponsabilities := fn:count($node/tei:persName[@type='sender'])
  for $responsability at $count in $node/tei:persName[@type='sender']
  return if ($count = $nbResponsabilities) then (getSender($responsability, $options), ' ')
    else (getSender($responsability, $options), ' ; ')
};

declare function getSender($node, $options as map(*)) {
    switch ($node)
    case ($node[@ref]) return <a href='/ampere/index-personnes{ $node/@ref }'>{ passthru($node, $options) }</a>
    default return passthru($node, $options)
};

declare function getAdressees($node, $options as map(*)) {
  let $nbResponsabilities := fn:count($node/tei:persName[@type='adressee'])
  for $responsability at $count in $node/tei:persName[@type='adressee']
  return if ($count = $nbResponsabilities) then (getAdressee($responsability, $options), ' ')
    else (getAdressee($responsability, $options), ' ; ')

};
declare function getAdressee($node, $options as map(*)) {
    switch ($node)
    case ($node[@ref]) return <a href='/ampere/index-personnes/{ $node/@ref }'>{ passthru($node, $options) }</a>
    default return passthru($node, $options)
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei biblio
 : ~:~:~:~:~:~:~:~:~
 :)

declare function listBibl($node, $options as map(*)) {
  <ul id="{$node/@xml:id}">{ passthru($node, $options) }</ul>
};

(:~
 : This function treats tei:analytic
 : @todo group author and editor to treat distinctly
 :)
declare function getAnalytic($node, $options as map(*)) {
  getResponsabilities($node, $options), 
  getTitle($node, $options)
};

(:~
 : This function treats tei:monogr
 :)
declare function getMonogr($node, $options as map(*)) {
  getResponsabilities($node, $options),
  getTitle($node, $options),
  getEdition($node/node(), $options),
  getImprint($node/node(), $options)
};


(:~
 : This function get responsabilities
 : @todo group authors and editors to treat them distinctly
 : @todo "éd." vs "éds."
 :)
declare function getResponsabilities($node, $options as map(*)) {
  let $nbResponsabilities := fn:count($node/tei:author | $node/tei:editor)
  for $responsability at $count in $node/tei:author | $node/tei:editor
  return if ($count = $nbResponsabilities) then (getResponsability($responsability, $options), '. ')
    else (getResponsability($responsability, $options), ' ; ')
};

(:~
 : si le dernier auteur mettre un séparateur à la fin
 :
 :)
declare function getResponsability($node, $options as map(*)) {
  if ($node/tei:forename or $node/tei:surname) 
  then getName($node, $options)
  else passthru($node, $options)
};

declare function persName($node, $options) {
    getName($node, $options)
};

(:~
 : this fonction concatenate surname and forname with a ', '
 :
 : @todo cases with only one element
 :)
declare function getName($node, $options as map(*)) {
  if ($node/tei:forename and $node/tei:surname)
  then (<span class="smallcaps">{$node/tei:surname/text()}</span>, ', ', $node/tei:forename)
  else if ($node/tei:surname) then <span class="smallcaps">{$node/tei:surname/text()}</span>
  else if ($node/tei:forename) then $node/tei:surname/text()
  else passthru($node, $options)
};

(:~
 : this function returns title in an html element
 :
 : different html element whereas it is an analytic or a monographic title
 : @todo serialize the text properly for tei:hi, etc.
 :)
declare function getTitle($node, $options as map(*)) {
  for $title in $node/tei:title
  let $separator := '. '
  return if ($title[@level='a'])
    then (<span class="title">« {$title/text()} »</span>, $separator)
    else (<em class="title">{$title/text()}</em>, $separator)
};

declare function getEdition($node, $options as map(*)) {
 $node/tei:edition/text()
};

declare function getMeeting($node, $options as map(*)) {
  $node/tei:meeting/text()
};

declare function getImprint($node, $options as map(*)) {
  for $vol in $node/tei:biblScope[@type='vol']
  return if ($vol[following-sibling::tei:*]) then ($vol, ', ')
    else ($vol, '. '), 
  for $pubPlace in $node/tei:pubPlace
  return 
    if ($pubPlace) then ($pubPlace/text(), ' : ')
    else 's.l. :',
  for $publisher in $node/tei:publisher
  return 
    if ($publisher) then ($publisher/text(), ', ')
    else 's.p.',
  for $date in $node/tei:date
  return
    if ($date and $node/tei:biblScope[@type='pp']) then (getDate($date, $options)(: $date/text() :), ', ')
    else if ($date) then (getDate($date, $options)(: $date/text() :), '.')
      else 's.d.',
  for $page in $node/tei:biblScope[@type='pp']
  return
    if ($page) then ($page, '.')
    else '.'
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei archives
 : ~:~:~:~:~:~:~:~:~
 :)
declare function listWit($node as element(tei:listWit)*, $options as map(*)) {
  <h4>Autres sources</h4>,
  <ul>{ passthru($node, $options) }</ul>
};

declare function witness($node as element(tei:witness)*, $options as map(*)) {
  <li id='{$node/tei:*/@xml:id}'>{ passthru($node, $options) }</li>
};

declare function archivesList($node as element(tei:msDesc)*, $options as map(*)) {
  let $numChem := $node/tei:msIdentifier/fn:substring-after(@xml:id, 'chem')
  return
    <table class="table">
      <tr>
        <td class="cell"><a href="/ampere/archives/{fn:concat('chem', $numChem)}">Chemise {$numChem}</a></td>
        <td class="cell">
          <h4>{$node/tei:msContents/tei:summary}</h4>
          <ul>{
            if ($node/tei:msContents/tei:msItem) 
            then 
              for $msItem in $node/tei:msContents/tei:msItem
              return <li><a href="/ampere/archives/chem{$numChem}#{$msItem/@xml:id}">Document {$msItem/fn:substring-after(@xml:id, fn:concat('chem', $numChem, '_'))}</a>: { passthru($msItem, $options) }</li>
            else ()  
          }</ul>
        </td>
      </tr>
    </table>
};

declare function msDesc($node as element(tei:msDesc)*, $options as map(*)) {
    switch  ($node)
    case ($node[parent::tei:sourceDesc]) return
      (<h4>Source de l&#39;édition numérique</h4>,
      <p>{
        if ($node[tei:msIdentifier/tei:country]) then ($node/tei:msIdentifier/tei:country, ', ') else (),
        if ($node[tei:msIdentifier/tei:settlement]) then ($node/tei:msIdentifier/tei:settlement, ', ') else (),
        if ($node[tei:msIdentifier/tei:institution]) then ($node/tei:msIdentifier/tei:institution, ', ') else (),
        if ($node[tei:msIdentifier/tei:repository]) then ($node/tei:msIdentifier/tei:repository, ', ') else (),
        if ($node[tei:msIdentifier/tei:idno]) then 
          (if ($node[tei:msIdentifier/tei:idno[fn:contains(., 'chemise')]]) 
          then (<a href='http://ampere.dev.huma-num.fr/ampere/archives/chem{fn:substring-after($node/tei:msIdentifier/tei:idno, 'chemise ')}'>{ $node/tei:msIdentifier/tei:idno }</a>)
          else ($node/tei:msIdentifier/tei:idno)  
  )
        else ('.')}</p>)
     case ($node[ancestor::tei:listWit]) return  
       (if ($node[tei:msIdentifier/tei:country]) then ($node/tei:msIdentifier/tei:country, ', ') else (),
       if ($node[tei:msIdentifier/tei:settlement]) then ($node/tei:msIdentifier/tei:settlement, ', ') else (),
       if ($node[tei:msIdentifier/tei:institution]) then ($node/tei:msIdentifier/tei:institution, ', ') else (),
       if ($node[tei:msIdentifier/tei:repository]) then ($node/tei:msIdentifier/tei:repository, ', ') else (),
       if ($node[tei:msIdentifier/tei:idno]) then 
         (if ($node[tei:msIdentifier/tei:idno[fn:contains(., 'chemise')]]) 
         then (<a href='http://ampere.dev.huma-num.fr/ampere/archives/chem{fn:substring-after($node/tei:msIdentifier/tei:idno, 'chemise ')}'>{ $node/tei:msIdentifier/tei:idno }</a>, '.')
         else ($node/tei:msIdentifier/tei:idno)  
  )
       else ('.'))
     default return ''
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : Surcharge
 : ~:~:~:~:~:~:~:~:~
 :)
 
declare function getCorpus($node as element()*, $options) {
  switch ($node)
  case ($node[ancestor::tei:TEI/tei:text/@type[fn:contains(., 'corr')]]) return $node/ancestor::tei:TEI/tei:text/@type
  case ($node[ancestor::tei:TEI/tei:text[fn:contains(@type, 'archives')]]) return 'archives'
  case ($node[ancestor::tei:TEI/tei:text/@type[fn:contains(., 'publi')]]) return $node/ancestor::tei:TEI/tei:text/@type
  default return ()
};

declare function graphic($node as element(tei:graphic), $options as map(*)) {
  if ($node/@url)
  then (<a href='{'/static/img/' || $node/ancestor::tei:TEI//tei:sourceDesc//tei:idno[@type='old'] || '/' || $node/@url}'><img class="displayed" width="400" height="400" src='{'/static/img/' || $node/ancestor::tei:TEI//tei:sourceDesc//tei:idno[@type='old'] || '/' || $node/@url}'/></a>)
  else ()
};

declare function ref($node as element(tei:ref), $options as map(*)) {
  switch ($node)
  case ($node[fn:contains(@target, 'chem')]) return <a href='/ampere/archives/{$node/fn:substring-after(@target, 'chem_')}'>{ passthru($node, $options) }</a>
  case ($node[fn:contains(@target, 'corr')]) return <a href='/ampere/correspondance/{$node/fn:substring-after(@target, 'corr_')}'>{ passthru($node, $options) }</a>
  case ($node[fn:contains(@target, 'publi')]) return <a href='/ampere/publications/{$node/fn:substring-after(@target, 'publi_')}'>{ passthru($node, $options) }</a>
  default return (<sup><a id='{'ref' || $node/fn:substring-after(@target, '#')}' href='{$node/@target}'>{ passthru($node, $options) }</a></sup>)
};

declare function choice($node as element(tei:choice), $options as map(*)) {
  switch ($node)
  case ($node[tei:abbr]) return <a href='#' class='infoAbbr'>{ passthru($node/tei:expan, $options) } <span>{ passthru($node/tei:abbr, $options) }</span></a>
  case ($node[tei:sic]) return <a href='#' class='infoAbbr'>{ passthru($node/tei:corr, $options) } <span>{ passthru($node/tei:sic, $options) } [sic]</span></a>
  default return <span class='choice'>{ passthru($node, $options) }</span>
};

(:~
 : @todo vérifier que la fonction marche
 :)
declare function gap($node as element(tei:gap), $options as map(*)) {
  switch ($node)
  case ($node[@reason='lacune']) return <span class='lacune'>[lacune]</span>
  case ($node[@reason='illisible']) return <span class='lacune'>[illisible]</span>
  case ($node[@reason='liste_botanique']) return <span class='lacune'>[liste botanique]</span>
  case ($node[@reason='liste_zoologique']) return <span class='lacune'>[liste zoologique]</span>
  case ($node[@reason='expressions__mathématiques']) return <span class='lacune'>[expressions mathématiques]</span>
  case ($node[@reason='imprimé']) return <span class='lacune'>[imprimé]</span>
  default return ()
};

declare function getIdItem($node as element()*, $options) {
  switch ($node)
  case ($node[fn:contains(@xml:id, 'ampere_publi_')]) return <a class="badge" href="/ampere/publications/{$node/fn:data(fn:substring-after(@xml:id, 'publi_'))}">{$node/fn:data(fn:substring-after(@xml:id, 'publi_'))}</a>
  case ($node[fn:contains(@xml:id, 'biblio_ouvrages_mentionnés')]) return <a class="badge" id="/ampere/publications-citées/{$node/fn:data(fn:substring-after(@xml:id, 'mentionnés_'))}">{$node/fn:data(fn:substring-after(@xml:id, 'mentionnés_'))}</a>
  case ($node[fn:contains(@xml:id, 'ampere_corr_')]) return <a class="badge" href="/ampere/correspondance/{$node/fn:data(fn:substring-after(@xml:id, 'corr_'))}">{$node/fn:data(fn:substring-after(@xml:id, 'corr_'))}</a>
  default return ()
};

declare function getId($node as element()*, $options) {
  switch ($node)
  case ($node[ancestor::tei:TEI/tei:teiHeader//tei:sourceDesc/tei:*/(@xml:id[fn:contains(., 'publi')])[1]]) return $node/ancestor::tei:TEI/tei:teiHeader//tei:sourceDesc/(tei:*[@xml:id])[1]/fn:data(fn:substring-after(@xml:id, 'publi_'))
  case ($node[(ancestor::tei:TEI/tei:teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/@xml:id[fn:contains(., 'arch')][1])]) return (($node/ancestor::tei:TEI/tei:teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier[@xml:id])/fn:data(fn:substring-after(@xml:id, 'arch_'))[1])
  case ($node[ancestor::tei:TEI/tei:teiHeader//tei:sourceDesc//tei:*/(@xml:id[fn:contains(., 'corr')][1])]) return ($node/ancestor::tei:TEI/tei:teiHeader//tei:sourceDesc//tei:*[@xml:id])[1]/fn:data(fn:substring-after(@xml:id, 'corr_'))
  default return ()
};

declare function getOtherEdition($node, $options) {
  if (fn:exists($node/ancestor::tei:listBibl/tei:biblStruct[fn:substring-after(@corresp, '#') = $node/@xml:id]) )
          then <ul>
            {for $f in $node/ancestor::tei:listBibl/tei:biblStruct[@corresp]
            where fn:substring-after($f/@corresp, '#') = $node/@xml:id
            return <li  id="{$f/@xml:id}"><a class="badge">{$node/fn:concat('P&#10548;', fn:substring-after($f/@xml:id, 'publi_P'))}</a>{ passthru($f, $options) }</li>}
                </ul>
          else ()
};

declare function biblItem($node as element(tei:biblStruct)*, $options) {
  for $node in $node[fn:not(@corresp)]
  return
    switch ($node) 
    case ($node[parent::tei:listBibl]) return 
      <li id="{$node/@xml:id}">
        { <b>{getIdItem($node, $options)}</b> }
        { passthru($node, $options) }
        {getOtherEdition($node, $options)}
      </li>
    case ($node[parent::tei:sourceDesc and $node[fn:contains(@xml:id, 'corr')]]) return 
      (<h4>Source de l&#39;édition numérique</h4>,
      <p>{
        passthru($node, $options),
        getIdItem($node, $options),
        getOtherEdition($node, $options)}</p>)
    default return  
         (passthru($node, $options),
         getIdItem($node, $options),
         getOtherEdition($node, $options) )
};
 
declare function idno($node as element(tei:idno), $options) {
  switch ($node)
  case ($node[@type='url_pdf']) return (<a href='{$node}'>[Lire le pdf]</a>)
  case ($node[@type='pdf']) return (<a href='/static/publications-PDF/{$node}'>[Lire le pdf]</a>)
  case ($node[@type='url_gallica']) return (<a href='{$node}'>[Lire sur Gallica]</a>)
  case ($node[@type='url_google']) return (<a href='{$node}'>[Lire sur google]</a>)
  case ($node[@type='url_cnum']) return (<a href='{$node}'>[Lire sur le CNUM]</a>)
  case ($node[@type='url_bio']) return (<a href='{$node}'>[Lire sur Biodiversity Heritage Library]</a>)
  case ($node[fn:contains(@type, 'url')]) return (<a href='{$node}'>[Lire le document]</a>)
  default return ()
};

declare function listPerson($node as element(tei:listPerson), $options) {
  <table>
    { passthru($node, $options) }
  </table>
};

declare function person($node as element(tei:person), $options) {
    for $person in $node[@xml:id]
    return
      <tr>
        <td>{ getName($person/tei:p/tei:persName, $options) }</td>
        {if ($person//tei:date) then <td>{ passthru($person//tei:date, $options) }</td> else <td></td>}
        {if ($person/tei:p[2][fn:not(tei:affiliation) and fn:not(tei:idno)]) then <td>{$person/tei:p[2]}</td> else <td></td> }
        {if ($person//tei:idno) 
        then 
          switch ($person//tei:idno) 
          case ($person//tei:idno[@type='viaf']) return <td><a href="{$person//tei:idno}">Viaf</a></td>
          case ($person//tei:idno[@type='data.BNF']) return <td><a href="{$person//tei:idno}">data.BNF</a></td>
          case ($person//tei:idno[@type='BNF']) return <td><a href="{$person//tei:idno}">BNF</a></td>
          default return <td><a href='{$person//tei:idno}'>{$person//tei:idno}</a></td>
        else ()}
      </tr>
};




