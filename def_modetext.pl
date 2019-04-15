

#-----------------------------------------------------------
# モード判定
#-----------------------------------------------------------
sub bbs_def_mode{

# 宣言
my($save);
our($css_text,$concept);

# CSS定義
$css_text .= qq(
.ruletitle{color:#f00;font-size:130%;}
.bmark{color:#f00;font-size:110%;}
.cmark{color:#000;font-size:110%;}
.colortext1{color:#060;}
.colortext2{color:#00b;}
);

	# ルール表示を整形
	foreach(split(/\n|<br>/,$rule_text)){
			if($_ eq ""){ next; }
		$_ =~ s/▼//g;
			if($kflag){ $save .= qq($emoji{'alert'}$_<br$main::xclose>\n); }
			else{ $save .= qq(<li>$_</li>\n); }
	}
	# 全体整形
	if($kflag){ $rule_text = qq($save); }
	else{ $rule_text = qq(<ol>$save</ol>); }

# 重複モードの定義テキスト

	if($concept =~ /MODE-SOUDANN/){
		$doublemark .= qq(▼重複ＯＫ（条件アリ）);
		$doubletext .= qq(この掲示板では、１相談＝１記事を使った方が良いような「個人的な相談」の場合、重複記事を作ってもかまいません。ただし、まとめられる場合は記事をまとめてください。);
	}

	elsif($concept =~ /DOUBLE-OK/){
		$doublemark .= qq(▼重複ＯＫ);
		$doubletext .= qq(この掲示板では、重複記事を作ってもかまいません。ただし、一人（または、特定のグループ）で、似た記事をいくつも作るのは控えてください。);
	}

	elsif($concept =~ /DOUBLE-GLAY/){
		$doublemark .= qq(▼重複やさしめ);
		$doubletext .= qq(この掲示板では、記事の種類が似ていても、わりに方向性が違えば削除されません。ただし「あまりにも似たコンセプトの記事」は作らないでください。);
	}

	elsif($concept =~ /MODE-CONCEPT/){
		$doublemark .= qq(▼重複やさしめ);
		$doubletext .= qq(この掲示板では、記事の種類が似ていても、わりに方向性が違えば削除されません。ただし「あまりにも似たコンセプトの記事」は作らないでください。);
	}

	elsif($sousaku_mode && $concept !~ /NOT-DOUBLE/){

		if($category eq "diary"){
			$doublemark .= qq(▼重複やさしめ);
			$doubletext .= qq(記事はなるべく使い切りましょう。一人であまり多くの記事は作らないでください。);
		}

		elsif($category eq "novel" || $category eq "diary"){
			$doublemark .= qq(▼重複ＯＫ);
			$doubletext .= qq(この掲示板は創作系なので、重複記事を気にしなくてもかまいません。ただし、一人（または、特定のグループ）で記事を作りすぎるのは、控えてください。);
		}
		else{
			$doublemark .= qq(▼重複やさしめ);
			$doubletext .= qq(この掲示板では、全く同じコンセプトの記事を作らないでください。);
		}

	}

	elsif($concept =~ /MODE-NITCH/){
		$doublemark .= qq(▼重複ＮＧ（ニッチ）);
		$doubletext .= qq(この掲示板では、重複記事を作ることは出来ません。<br$xclose>
		コンセプトのない「総合記事」「単なる語り記事」は、ほぼ重複するので注意してください（<a href="${guide_url}%A5%B8%A5%E3%A5%F3%A5%EB%CA%AC%A4%B1">ジャンル分けのガイドを参照</a>）。<br$xclose>
		ただし、たとえば「作品Ａの攻略法」と「作品Ａのキャラについて」という二つの記事は、コンセプトが違うので作ってかまいません。
		);
		$ngjuufukuflag = 1;
	}

	elsif($concept !~ /ZATUDANN-OK/){
		$doublemark .= qq(▼重複ＮＧ);
		$doubletext .= qq(この掲示板では、重複記事を作ることは出来ません。たとえば、同じゲームや、同じアーティストの記事はひとつまでです。);
		$ngjuufukuflag = 1;
	}

	else{
		$ngjuufukuflag = 1;
	}



# 雑談モードの定義テキスト

if($concept =~ /ZATUDANN-OK1/){
$zatudannmark .= qq(▼雑談ＯＫ);
$zatudanntext .= qq(この掲示板は”雑談系”なので、雑談記事があってもかまいません。特にコンセプトがなくてもＯＫです。);
}

elsif($concept =~ /ZATUDANN-OK2/){
$zatudannmark .= qq(▼雑談ＯＫ（条件アリ）);
$zatudanntext .= qq(この掲示板は”準雑談系”です。雑談記事があってもかまいませんが、「コンセプトの似た雑談記事（重複記事）」は削除対象なので、注意してください。「コンセプトのない、ただの雑談記事」は重複しやすいです。);
}

elsif($concept =~ /ZATUDANN-OK3/){
$zatudannmark .= qq(▼雑談ＯＫ（条件アリ）);
$zatudanntext .= qq(この掲示板では雑談記事を作ることが出来ますが、このカテゴリと全く関係ないものは禁止です。);
}


else{
$zatudannmark .= qq(▼雑談ＮＧ);
$zatudanntext .= qq(この掲示板は”カテゴリ系”です。雑談記事を作ることは出来ません。);
}

# 全体ルールの定義

$allrulemark .= qq(▼全体ルール);
if(!$secret_mode){ $deletermark .= qq(▼削除依頼); }

my($klink) = qq(-k) if($kflag);

$allruletext .= qq(<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">メビウスリング禁則</a>が基本ルールです。詳しくは<a href="$guide_url">総合ガイドライン</a>もごらんください。);
if(!$secret_mode){ $deletertext .= qq(<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">ルール違反</a>を見つけたら、<a href="${base_url}_delete/$kboad">削除依頼掲示板</a>までご連絡ください。<a href="all-deleted$klink.html#M" rel="nofollow" class="red">削除済み記事の一覧</a>もあります。); }

# ＰＣならマーク色づけ
if(!$kflag){
$doublemark = qq(<strong class="bmark">$doublemark</strong>);
$zatudannmark = qq(<strong class="bmark">$zatudannmark</strong>);
$allrulemark = qq(<strong class="cmark">$allrulemark</strong>);
$deletermark = qq(<strong class="cmark">$deletermark</strong>);
}

	# ＰＣ版ならテキスト色づけ
	if(!$kflag){
		$doubletext = qq(<span class="colortext1">$doubletext</span>);
		$zatudanntext = qq(<span class="colortext1">$zatudanntext</span>);
		$allruletext = qq(<span class="colortext2">$allruletext</span>);
		$deletertext = qq(<span class="colortext2">$deletertext</span>);
	}

# テキスト整形
$doubletext = qq(<div>$doublemark<br$xclose>$doubletext</div>\n);
$zatudanntext = qq(<div>$zatudannmark<br$xclose>$zatudanntext</div>\n);
$allruletext = qq(<div>$allrulemark<br$xclose>$allruletext</div>\n);
$deletertext = qq(<div>$deletermark<br$xclose>$deletertext</div>\n);

# 最終定義（シークレット板）
if($secret_mode){
my($candel_text);
if($candel_mode){ $candel_text = qq(自分の書き込みは自主削除してください。); }
$pefrule_text = "";
$rule_text = qq(▼このルールの他に「管理者のピン止め記事」のルールに従ってください。<br$xclose>
<a href="member.html">▼メンバーリストはこちらから確認できます。</a><br$xclose>
▼基本的にこの掲示板の存在は、公の場所では触れないようにしてください。
▼パスワードの貸し借り、共有、譲渡は禁止です。「ユーザー名」「パスワード」は本人様のみがお使いください。<br$xclose>
▼「メビウスリングの他の場所」や「外部サイト」に、この掲示板のＵＲＬを貼\り付けたり、この掲示板からの引用・転載をおこなわないでください。<br$xclose>
▼ルールに反した場合など、管理者の独断で、予\告なしにメンバー登録を解除させていただく場合があります。<br$xclose>
▼削除依頼がある場合、（削除依頼板は利用せず）この掲示板内に書くか、<a href="scmail.html">管理者宛にメール</a>してください。$candel_text<br$xclose>
▼掲示板を閲覧・利用できるのは「現メンバー」「招待をおこなった管理者(１人)」のみです。ただし緊急の場合など、加えて「総合管理者（愛浦☆マスター）」が管理させていただく場合もあります。
);
}
	# 最終整形（通常）
	else{
			if($kflag){ $pefrule_text .= qq($doubletext $zatudanntext $allruletext $deletertext); }
			else{ $pefrule_text .= qq(<div>$doubletext $zatudanntext $allruletext $deletertext</div>); }
	}

return($rule_text,$zatudanntext,$doubletext,$ngjuufukuflag,$pefrule_text);

}


1;
