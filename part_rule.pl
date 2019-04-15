
use Mebius::BBS;
package main;

#-----------------------------------------------------------
# 掲示板のルール表示
#-----------------------------------------------------------

sub bbs_rule_view{

# 宣言
my($rule_text,$zatudann_text);
our($mode,$moto,$server_domain,$device_type,$divide_url,$now_url,$sub_title,$head_link3,$css_text);
our($kfontsize_h1);

# カテゴリ設定を取得
my($init_category) = Mebius::BBS::init_category_parmanent($main::category);

	# アクセス振り分け
	if($mode eq "rule"){
		$divide_url = "http://$server_domain/_$moto/krule.html";
			#if($device_type eq "mobile"){ &divide($divide_url,"mobile"); }
	}
	elsif($mode eq "krule"){
		$divide_url = "http://$server_domain/_$moto/rule.html";
			#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }
	}

	# 携帯版
	if($mode eq "krule"){ &kget_items(); }

	# タイトル定義
	if($mode eq "rule"){ $sub_title = "$titleのルール"; }
	else{ $sub_title = "$titleのルール | 携帯版"; }
$now_url ="_$moto/rule.html";
$head_link3 = "&gt; ルール";

# モード判定
my($rule_text,$zatudann_text,$none,$none,$pefrule_text,$category_rule) = &bbs_def_mode();

	# カテゴリルールを整形
	if(Mebius::BBS::secret_judge()){
		$category_rule = "";
	} elsif($category_rule){
		$category_rule = qq(<h2$kfontsize_h2>$init_category->{'title'} カテゴリのルール</h2>\n$category_rule);
	}

# CSS定義
$css_text .= qq(
.rulebox{color:#222;padding:0.75em 1.5em;font-weight:bold;}
.ruleplus{border:dotted 2px #f00;padding:1em 1.25em;line-height:1.5em;}
div.text{line-height:2.3em;}
li{text-decoration:underline;line-height:2.0em;}
ol{margin-bottom:1em;}
a.marker{padding:0.2em 0.5em;margin:0em 0.5em;border:1px dotted #00f;}
);


my $print = qq(
$category_rule
<h2$kfontsize_h2>$titleのルール</h2>
$rule_text
<div class="text">$pefrule_text</div>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-----------------------------------------------------------
# モード判定
#-----------------------------------------------------------
sub bbs_def_mode{

# 宣言
my($save);
my($category_rule);
our($css_text,$concept);

my(%emoji) = Mebius::Emoji;
my($emoji_shift_jis) = Mebius::Encoding::hash_to_shift_jis(\%emoji);


# カテゴリ設定を取得
my($init_category) = Mebius::BBS::init_category_parmanent($main::category);


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
		my($style);
			if($_ eq ""){ next; }
		$_ =~ s/▼//g;
		$_ =~ s!<a href="(.+?)">(.+)</a>!<a href="$1" class="marker">$2</a>!g;
		if($_ =~ s/^!//g){ $_ = qq(<span style="color:#f00;">$_</span>);  $style = qq( style="color:#f00;"); }
			if($kflag){ $save .= qq($emoji_shift_jis->{'alert'}$_<br$main::xclose>\n); }
			else{ $save .= qq(<li$style>$_</li>\n); }
	}
	# 全体整形
	if($kflag){ $rule_text = qq($save); }
	else{ $rule_text = qq(<ol>$save</ol>\n); }

	# カテゴリルールを整形
	my(%category) = Mebius::BBS::init_category(undef,$main::category);
	foreach(split(/\n|<br>/,$init_category->{'rule'})){
		my($style);
			if($_ eq ""){ next; }
		$_ =~ s!<a href="(.+?)">(.+?)</a>!<a href="$1" class="marker">$2</a>!g;
		if($_ =~ s/^!//g){ $_ = qq(<span style="color:#f00;">$_</span>); $style = qq( style="color:#f00;"); }
			if($kflag){ $category_rule .= qq($emoji_shift_jis->{'alert'}$_<br$main::xclose>\n); }
			else{ $category_rule .= qq(<li$style>$_</li>\n); }
	}
	# 全体整形
	if($category_rule){
			if($kflag){ $category_rule = qq($category_rule); }
			else{ $category_rule = qq(<ol>$category_rule</ol>\n); }
	}

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
		$doubletext .= qq(この掲示板では、記事の種類が似ていても、わりに方向性が違えば削除されません。ただし「あまりにも似たテーマの記事」は作らないでください。);
	}

	elsif($concept =~ /MODE-CONCEPT/){
		$doublemark .= qq(▼重複やさしめ);
		$doubletext .= qq(この掲示板では、記事の種類が似ていても、方向性が違えば削除されません。ただし「あまりにも似たテーマの記事」は作らないでください。);
	}

	elsif($main::bbs{'concept'} =~ /Sousaku-mode/ && $concept !~ /NOT-DOUBLE/){

		if($category eq "diary"){
			$doublemark .= qq(▼重複やさしめ);
			$doubletext .= qq(記事はなるべく使い切りましょう。一人であまり多くの記事は作らないでください。);
		}

		elsif($category eq "novel" || $category eq "diary"){
			$doublemark .= qq(▼重複ＯＫ);
			$doubletext .= qq(この掲示板は創作系なので、重複記事を気にしなくてもかまいません。ただし、記事の乱立はご遠慮ください。);
		}
		else{
			$doublemark .= qq(▼重複やさしめ);
			$doubletext .= qq(この掲示板では、全く同じテーマの記事を作らないでください。);
		}

	}

	elsif($concept =~ /MODE-NITCH/){
		$doublemark .= qq(▼乱立ＮＧ（ニッチ）);
		$doubletext .= qq(この掲示板では、マニアックな話題ごとに記事を作ったり、新しい企画ごとに記事を作ってもかまいません。<br$main::xclose>
		ただし完全な重複や、記事の乱立は削除させていただく場合があります。
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
		$zatudanntext .= qq(この掲示板は”雑談系”です。特にテーマのない雑談記事があってもかまいません。);
	}

	elsif($concept =~ /ZATUDANN-OK2/){
		$zatudannmark .= qq(▼雑談ＯＫ（条件アリ）);
		$zatudanntext .= qq(この掲示板は”準雑談系”です。雑談専用の記事を作ってもかまいませんが、似たテーマの【重複記事】にならないよう注意してください。もし記事を雑談化させたくない場合は、カテゴリ別の掲示板をご利用ください（例：ゲーム掲示板など）。);
	}

	elsif($concept =~ /ZATUDANN-OK3|MODE-NITCH/){
	$zatudannmark .= qq(▼雑談ＮＧ);
		$zatudanntext .= qq(この掲示板は”カテゴリ系”です。原則雑談は禁止です。（２０１０年９月より）);
	}
	else{
		$zatudannmark .= qq(▼雑談ＮＧ);
		$zatudanntext .= qq(この掲示板は”カテゴリ系”です。雑談記事を作ることは出来ません。);
	}

# 全体ルールの定義

$allrulemark .= qq(<h2$kfontsize_h2>全体ルール</h2>);

my($klink) = qq(-k) if($kflag);

$allruletext .= qq(マナー違反、個人情報掲載、メルアド記載、出会い行為、宣伝、文字羅列、AA等はご遠慮ください。( <a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">→詳しく読む</a> ) );
if(!$secret_mode){ $deletertext .= qq(<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">ルール違反</a>を見つけた場合は、<a href="${base_url}_delete/">削除依頼掲示板</a>までご連絡ください。<a href="all-deleted$klink.html#M" rel="nofollow" class="red">削除済み記事の一覧</a>もあります。); }

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
$doubletext = qq(<div>$doublemark<br$main::xclose>$doubletext</div>\n);
$zatudanntext = qq(<div>$zatudannmark<br$main::xclose>$zatudanntext</div>\n);
$allruletext = qq(<div>$allrulemark $allruletext</div>\n);
$deletertext = qq(<div>$deletermark $deletertext</div>\n);

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

return($rule_text,$zatudanntext,$doubletext,$ngjuufukuflag,$pefrule_text,$category_rule);

}


1;




1;
