let $content         := "blanc noir"

let $stop :=  db:open("stopword")/stopword/orth

let $txt := ft:tokenize($content) 

let $corpus :=distinct-values($txt)[not(.=$stop)][string-length(.)>2] 

let $cloud := for $w in $corpus, $y in distinct-values(db:open("morphalou")/lexicon/lexicalEntry[./formSet/inflectedForm/orthography=$w]/formSet/lemmatizedForm/orthography), $z in db:open("LEXI_CLOUD_SITE")/cloud/source[@mot=$y]//cible[not(.=$y)][.=$corpus]

let $freq := count($txt[upper-case(.) eq upper-case($w)])
return <li mot="{$w}" lemme="{$y}" value="{$freq}">{for $x in distinct-values($z) return <link>{$x}</link>, <type>{node-name($z/..)}</type>}</li>

return

let $noeuds := for $x at $p in distinct-values($cloud/@mot)return <li name="{$x}" num="{$p}" couleur="#78BBFE"/>

let $noeuds1 := ($noeuds,(for $x at $p in distinct-values($cloud/link) return if (not($x=$noeuds/@name)) then <li name="{$x}" num="{$p+count($noeuds)}" couleur="#FFA500"/> else ()))

let $liens:= for $x in $noeuds1, $y in distinct-values($cloud[./@mot=$x/@name]/link) return <li deb="{$x/@num}" fin="{$noeuds1[./@name=$y]/@num}" value="{if ($cloud[./@mot=$x/@name and ./link=$y][1]/type="antonyme") then "-" else if ($cloud[./@mot=$x/@name and ./link=$y][1]/type="synonyme") then "=" else "+"}" mesure="{if ($cloud[./@mot=$y][1]/@value) then $cloud[./@mot=$y][1]/@value else $cloud[./link=$y][1]/@value}"/>

return
(<div>
<ul id="noeuds">
<li name="TEXTE" num="0" couleur="#AAAAAA"/>
{
$noeuds1
}
</ul>
<ul id="liens">
{$liens}{for $i in distinct-values($liens/@deb) return if (count(for $j in $liens[./@deb=$i]/@fin return $j)>1) then for $p at $q in (1 to count(for $j in $liens[./@deb=$i]/@fin return $j)),$j in $liens[./@deb=$i]/@fin[$p], $k in $liens[./@deb=$i]/@fin[not(.=$j)] return <li deb="{$j}" fin="{$k}" value="?" mesure="2"/>
else () }
</ul>
</div>)
                
