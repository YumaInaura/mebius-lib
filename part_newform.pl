
package main;

#-------------------------------------------------
# 新規投稿前の説明書き
#-------------------------------------------------
sub bbs_newform{

# 宣言
my($newwait_flag,$newwait_dayhourmin,$nextwait_dayhour,$bonusform_flag,$nextbutton_disabled);
our($mode,$selected,$moto,$server_domain,$google_oe,$sub_title,$head_link3,$css_text,$agent);
our(%in);

	# モード振り分け（２）
	if($mode eq "kform" || $mode eq "kruleform"){ &kget_items(); }
	if($mode eq "ruleform" || $mode eq "kruleform"){ &bbs_second_newform(); }

# タイトル定義
$sub_title = "新規投稿フォーム | $title";
$head_link3 = "&gt; 新規投稿フォーム";

	# ストップモード
	if(Mebius::Switch::stop_bbs()){
		my $print = qq(現在、掲示板全体で投稿停止中です。);
		Mebius::Template::gzip_and_print_all({},$print);
		exit;
	}

# Google検索フォーム
my($domain);
if($server_domain eq "aurasoul.mb2.jp"){ $domain = "aurasoul.mb2.jp"; } else{ $domain = "mb2.jp"; }
$newform_google_form = qq(
<form method="get" action="http://www.google.co.jp/search">
<div class="google_bar google_bar2">
<a href="http://www.google.co.jp/" rel="nofollow">
<img src="http://www.google.co.jp/logos/Logo_25wht.gif" class="google_img" alt="Google"$xclose></a>
<span class="vmiddle">
<select name="sitesearch" class="site_select">
<option value="mb2.jp">メビウスリング</option>
<option value="$domain/_$moto"$selected>$title</option>
<option value="">ウェブ全体(www)</option>
</select>
<input type="text" name="q" size="31" maxlength="255" value="" class="ginp"$xclose>
<input type="submit" name="btnG" value="Google 検索"$xclose>
<input type="hidden" name="ie" value="Shift_JIS"$xclose>
$google_oe
<input type="hidden" name="hl" value="ja"$xclose>
<input type="hidden" name="domains" value="mb2.jp"$xclose>
</span></div>
</form>
);


# CSS定義
$css_text .= qq(
.google_bar2{float:none !important;margin:1em 0em !important;}
td.alert,td.alert2{font-size:90%;border-style:none;color:#f00;padding:0em 0em 0.5em 0em;}
.table2{width:100%;}
);



	# 第二画面、ローカルルールチェックへ
	if($in{'newform_check'} == 1){

		# ～時間以内にレスをしていないと、新規投稿できない
		Mebius::BBS::PostAfterResCheck("Error-view");

		Mebius::Redirect("","ruleform.html");
	}

	# 最終投稿フォームへ
	elsif($in{'newform_check'} == 2){
		if($in{'newcheck_p1'} && $in{'newcheck_p2'} && $in{'newcheck_p3'} && $in{'newcheck_p4'} && !$in{'newcheck_ng'}){ &bbs_last_newform(); }
		else{ &error("新規投稿の説明をご確認ください。"); }
	}
	elsif($in{'type'} eq "image"){ &bbs_last_newform(); }

# 新規待ち時間を取得
require "${int_dir}part_newwaitcheck.pl";
($newwait_flag,$newwait_dayhourmin,$nextwait_dayhour,$bonusform_flag) = &sum_newwait();
&sum_newwait_penalty();
if($newwait_flag){ $nextbutton_disabled = $disabled; }

# かんたん新規投稿フォーム(設定ファイルより）
if($fastpost_mode || ($bbs{'concept'} =~ /Fast-post-mode/ && !$newwait_flag)){ &bbs_last_newform("FAST",$nextwait_dayhour); }

# 記事数が少ない場合
if($bonusform_flag && !$newwait_flag){ &bbs_last_newform("FAST",$nextwait_dayhour); }

# 現行インデックスから、延べ記事数を取得
open(IN,"$nowfile");
my$top = <IN>; chomp $top;
my($num) = split(/<>/,$top);
close(IN);


# 最早フォームの解説テキスト
if($newwait_flag){ $formtext1 = qq(現在、待ち時間中です ( 残り $newwait_dayhourmin ));}
else{ $formtext1 = qq(”$head_title”への新規投稿); }

# 共通の注意書き（上部）
$newpost_guide = qq(
<strong class="size180" style="color:#f00;">注意！</strong><br$xclose>
<strong class="red">このページの説明をよく読まないと、
記事が削除されたり、掲示板に書き込めなくなることがあります。<br$xclose>
あなたの作った記事が削除されると、何日か新規投稿できなくなる場合がありますので、ご注意ください。</strong><br$xclose>
少し長いですが、ゆっくりと、全ての箇所に目を通してください。<br$xclose>
リンク先も全てチェックしましょう。（<a href="${guide_url}%CA%CC%C1%EB%A4%C7%B3%AB%A4%AF">別窓で開くと便利です</a>）
▼<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">新規投稿</a>をすると、<a href="./">$title</a>に新しい記事（ページ）を増やすことが出来ます。
ひとつの記事には、$m_max回までレス（返信）が出来ます。
<br$xclose>
▼一度、<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">新規投稿</a>をすると、
次に新しい記事が作れるようになるまで、<strong class="red">$new_wait時間</strong>（目安）ほどの待ち時間が出来ます。（普通の返信はいつでも可\能\です）
);


# 最下部チェックフォーム
$lastcheck_guide = qq(
<form action="./" method="post"$sikibetu><div>
▼全ての確認が済んだら、次の内ふさわしい箇所にチェックを入れて、送信ボタンを押してください。<br$xclose>
<strong class="red">（その前に、１時間ほどかけてこのページをチェックし、リンク先もよく読むことをお勧めします）</strong>
<br$xclose>
<input type="hidden" name="mode" value="form"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="checkbox" name="newform_check" value="1" id="agree_rule"$xclose>
<strong><label for="agree_rule">はい、私は新規投稿のルールを全て守り、責任を持って記事を作ります。</label></strong>
<input type="submit" value="ルール確認を終えて、次のページに進む"$nextbutton_disabled$xclose>
</div></form>
);


# 説明部分を取得
($juufuku_guide) = &newform_get_juufuku_guide();
($other_guide) = &newform_get_other_guide();

# HTML
my $print = qq(
<h1 style="color:#070;$main::kstyle_h1_in">$formtext1</h1>
<div style="line-height:2;">
$newpost_guide
$juufuku_guide
$other_guide
$lastcheck_guide
</div>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# その他の新規投稿ルール
#-----------------------------------------------------------
sub newform_get_other_guide{

# 宣言
my($line);

# 注意書き(共通)
$line .= qq(
<h2$main::kstyle_h2>基本ルール</h2>
▼新規投稿にあたって、必ず次のルールを守ってください。（<strong class="red">ルール違反の記事は削除されます</strong>）<br$xclose>
$juufuku_ng_link
→<a href="${guide_url}%A5%AB%A5%C6%A5%B4%A5%EA%B0%E3%A4%A4">カテゴリにふさわしい記事を作る</a>（あるべき掲示板に、あるべき記事を作りましょう）<br$xclose>
);

# 性的な表現
if($main::bbs{'concept'} =~ /Sousaku-mode/){
$line = qq(
→<a href="${guide_url}%C0%AD%C5%AA%A4%CA%C9%BD%B8%BD">性表\現が含まれる記事では<span style="font-size:140%;">投稿フォームで適切なチェックを入れる</span></a>
（18歳以上）<br$xclose>
);
}

# ショッキングな表現
if($main::bbs{'concept'} =~ /Sousaku-mode/ && $category ne "diary"){
$line2 .= qq(→<a href="${guide_url}%A5%B7%A5%E7%A5%C3%A5%AD%A5%F3%A5%B0%A4%CA%C9%BD%B8%BD">ショッキングな表\現が含まれる記事では<span style="font-size:140%;">投稿フォームで適切なチェックを入れる</span></a>
（15歳以上。イジメ作品、暴\力を含む作品、グロテスク作品など）<br$xclose>);
}

# 創作の題名
if($main::bbs{'concept'} =~ /Sousaku-mode/ && $category ne "diary"){ $line2 .= qq(→<a href=\"${guide_url}%C1%CF%BA%EE%A4%CE%C2%EA%CC%BE\">記事の題名には作品名を使う</a>（創作の雰囲気が大事です）<br$xclose>); }


# 注意書き(普通モードのみ)
if($main::bbs{'concept'} !~ /Sousaku-mode/){
$line .= qq(
→<a href="${guide_url}%B5%AD%BB%F6%A4%CE%A5%B3%A5%F3%A5%BB%A5%D7%A5%C8">分かりやすい題名を使い、テーマは一つに絞る。</a>（読者が記事を見つけやすくなります）<br$xclose>
→<a href="${guide_url}%B8%C4%BF%CD%C5%AA%A4%CA%B5%AD%BB%F6">個人的な記事を作らない。</a>（記事は利用者全員のものです）<br$xclose>
→<a href="${guide_url}%BB%B2%B2%C3%BC%D4%A4%CE%C0%A9%B8%C2">「年齢／学年／性別／居住地／職業」で参加者を決めたり、人を集めたりしない。</a>（話題中心の記事作りをしましょう）<br$xclose>
→<a href="${guide_url}%C3%B1%C8%AF%BC%C1%CC%E4">単発質問をしない</a>（長い間、使い続けられる記事を作りましょう）<br$xclose>
→<a href="${guide_url}%C0%AD%C5%AA%A4%CA%C5%EA%B9%C6">性的な相談、議論をする場合は、投稿フォームで適切なチェックを入れ、本文にも注意書きを入れる</a>（読みたくない人が、読む前に考えられるようにしましょう）。<br$xclose>
);
}

# 注意書き(共通)
$line .= qq(
$vio_link
→<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">禁則投稿（ルール違反）をしない</a>（メビウスリングのルールを守れば、記事が削除されません）<br$xclose>
);

return($line);

}


#-----------------------------------------------------------
# 重複記事の説明部分
#-----------------------------------------------------------

sub newform_get_juufuku_guide{

# 宣言
my($line,$rule_text,$zatudanntext,$doubletext,$ngjuufukuflag);
our($category,$int_dir,$xclose,$guide_url,$newform_google_form);

# モード判定
require "${int_dir}part_rule.pl";
($rule_text,$zatudanntext,$doubletext,$ngjuufukuflag,$pefrule_text,$category_rule) = &bbs_def_mode();


# 詩、他創作の場合、重複ＯＫフラグがない場合
if($category eq "poemer" && $concept !~ /POEM-ONE/){
$line = qq(
<strong>２.似たテーマの記事について</strong><br$xclose>
▼基本的に、今ある記事をうまく使ってください。<br$xclose>
▼あなたがいま作ろうとしている記事は、本当に必要ですか？　
まずは<a href="find.html">記事検索</a>やウェブ検索を使って、
あなたが魅かれる記事や、あなたの投稿目的にあった記事を探してみましょう。
ふさわしい記事がある場合、必ずそちらを使ってください。
<br$xclose>
<form action="./"><div>
▼ひとつの掲示板に、同じテーマの作品記事は、二つは要りません。
<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">新規投稿</a>する前に、
似たようなテーマの作品記事がないか、必ず調べてください。
<input type="hidden" name="mode" value="find"$xclose>
<input type="text" name="word" value="" size="18" style="width:10em;"$xclose>
<input type="submit" value="記事検索">
</div></form>
$newform_google_form
<span class="guide">※たとえば「メビウスリング～心に綴る詩～」という記事を作りたい場合、
「メビウス」「リング」「mebi」「輪」「心」「ハート」「想い」など、考えられる色々なパターンを使って検索してみてください。
</span><br$xclose>
);
}

# 小説、日記などの場合
elsif($main::bbs{'concept'} =~ /Sousaku-mode/){
$line = qq(
<strong>２.記事を作るカテゴリについて</strong><br$xclose>
▼あなたがいま作ろうとしている記事は、掲示板のカテゴリに合ったものですか？
<a href="/">ＴＯＰページ</a>を確認して、もっとふさわしい場所がある場合、そちらに記事を作ってください。<br$xclose>
▼カテゴリ選びの例：　小説書き始めの人は「小説→初心者」へ。ト書きの小説は「小説→ト書」へ。ポエムっぽいエッセイは「エッセイ→詩１」などへ。<br$xclose>
▼一度記事を作ると、後から題名や内容の変更は出来ません。内容をよく確認してください。（プレビューモードを活用しましょう）<br$xclose>
▼一つの掲示板に、二つ以上の記事を作る場合は、必要性をよく考えましょう。<br$xclose>
);
}

	# ノーマルモード - 重複NGの場合
	elsif($ngjuufukuflag){
$line .= qq(
<h2$main::kstyle_h2>重複記事は禁止です</h2>
▼基本的に、今ある記事をうまく使ってください。<br$xclose>
▼あなたがいま作ろうとしている記事は、本当に必要ですか？
　<a href="find.html">記事検索</a>やウェブ検索で、他にふさわしい記事が出てくる場合、
必ずそちらを使ってください。
<br$xclose>
<form action="./"><div>
▼ひとつの掲示板に、同じような記事は、二つは要りません。
<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">新規投稿</a>する前に、
<a href="${guide_url}%BD%C5%CA%A3%B5%AD%BB%F6">似たような記事</a>がないか、必ず検索してください。
<input type="hidden" name="mode" value="find"$xclose>
<input type="hidden" name="log" value="0"$xclose>
<input type="text" name="word" value="" size="18" style="width:10em;"$xclose>
<input type="submit" value="記事検索"$xclose>
</div></form>
$newform_google_form
<span class="guide">※たとえば「メビウスリング～心に綴る詩～」という記事を作りたい場合、
「メビウス」「リング」「mebi」「輪」「心」「ハート」「想い」など、考えられる色々なパターンを使って検索してみてください。
</span>
);
	}

# ノーマルモード - 重複ＯＫ，重複やさしめの場合
else{ $line .= qq(<h2$main::kstyle_h2>重複記事は禁止です</h2>$doubletext); }

return($line);

}

#-----------------------------------------------------------
# ２番目のルール確認フォーム
#-----------------------------------------------------------
sub bbs_second_newform{

# 宣言
my($rule_text,$print);
our($title,$sub_title,$head_link3,$css_text,$kinputtag,$khrtag,$xclose);
our($int_dir,$guide_url);

# カテゴリ設定を取得
my($init_category) = Mebius::BBS::init_category_parmanent($main::category);

# ヘッダタイトル＆リンク定義

# タイトル定義
$sub_title = "新規投稿フォーム | $title";
$head_link3 = "&gt; 新規投稿フォーム";



# CSS定義
$css_text .= qq(
div.local_rule{padding:1em;border:solid 1px #f00;line-height:1.8;}
div.check_list{line-height:1.8;}
div.promise_list{font-size:150%;line-height:1.5;text-decoration:underline;}
);

# モード判定
require "${int_dir}part_rule.pl";
($rule_text,$zatudanntext,$doubletext,$ngjuufukuflag,$pefrule_text,$category_rule) = &bbs_def_mode();



	if($rule_text){ 
		$rule_text = qq(<h2 class="red"$main::kstyle_h2>●$titleのルール</h2>$rule_text);
	}

my(%category) = Mebius::BBS::init_category();

	if($category_rule){ 
		$category_rule = qq(<h2 class="red"$main::kstyle_h2>●$init_category->{'title'}カテゴリのルール</h2>$category_rule);
	}


# ローカルルール
$print .= qq(
<form action="./" method="post"><div>
<div class="local_rule">
新規投稿にあたって、次のルールを必ず守ってください。<br$xclose>
$rule_text
$category_rule
$zatudanntext
$doubletext
</div>
<br$xclose>▼ルールはよく理解できましたか？
<input type="radio" name="newcheck_p1" value="1" id="rulecheck_yes"$xclose><label for="rulecheck_yes">はい</label>
<input type="radio" name="newcheck_p1" value="0" id="rulecheck_no"$xclose><label for="rulecheck_no">いいえ</label>
　（→分からない時は<a href="http://aurasoul.mb2.jp/_qst/">質問掲示板</a>へ）
);


# チェックリスト
$print .= qq(
<h2$main::kstyle_h2>●チェックリスト</h2>
<div class="check_list">
全ての確認が済んだら、ふさわしい箇所にチェックを入れて、送信ボタンを押してください。<br$xclose>
<strong class="red">（このページも、３０分以上をかけてじっくり読み、リンク先も全てチェックすることをお勧めします）</strong><br$xclose>
（→<a href="form.html">何か分からないことがあれば、ひとつ前の説明に戻りましょう</a>）
<h3$main::kstyle_h3>▼新規投稿チェックリスト</h3>
<div class="promise_list">
<input type="hidden" name="mode" value="form"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="hidden" name="newform_check" value="2"$xclose>

<input type="checkbox" name="newcheck_p2" value="1" id="newcheck_p2"$xclose>
<strong><label for="newcheck_p2">１．私は、$titleのローカルルールを全て理解しました。</label></strong><br$xclose>

<input type="checkbox" name="newcheck_p3" value="1" id="newcheck_p3"$xclose>
<strong><label for="newcheck_p3">２．私は、もしルール違反があった場合、予\告なしに記事を削除されてもかまいません。</label></strong><br$xclose>

<input type="checkbox" name="newcheck_p4" value="1" id="newcheck_p4"$xclose>
<strong><label for="newcheck_p4">３．私は「カテゴリにふさわしくない記事」「<a href="${guide_url}%BD%C5%CA%A3%B5%AD%BB%F6">重複記事</a>」など迷惑な記事、ルールに反する記事は作成しません。</label></strong><br$xclose>

<input type="checkbox" name="newcheck_ng" value="1" id="newcheck_ng"$xclose>
<strong><label for="newcheck_ng">４．私は、ルールを完全には確認しなかったので、意味のない箇所にもチェックを入れてしまいます。</label></strong><br$xclose>
</div>
題名: <input type="text" name="sub" value=""$xclose>
<input type="submit" value="全ての確認を終えて、新規投稿フォームに進む" class="isubmit"$xclose>
</div>
</div>
</form>

);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}

#-----------------------------------------------------------
# 最終投稿フォーム
#-----------------------------------------------------------
sub bbs_last_newform{

# 宣言
my($type,$nextwait_dayhour) = @_;
my($guide,$resform,$print);
our($sub_title,$head_link3,$css_text);

# タイトル定義
$sub_title = "新規投稿フォーム - $title";
$head_link3 = "&gt; 新規投稿フォーム";

# CSS定義
$css_text .= qq(
.sexvio{color:#f00;font-weight:bold;font-size:90%;}
td.alert{font-size:90%;border-style:none;color:#f00;padding:0em 0em 0.5em 0em;}
.ipreview{color:#00f;}
div.lastform_guide{line-height:1.4;}
);

	# 投稿フォームを取得 ( PC版 )
	if(!$kflag){
		require "${int_dir}part_resform.pl";
		($resform) = &bbs_thread_form({ NewMode => 1 , GetMode => 1 });
	}

	# 秘密モード
	if($secret_mode){ $guide = qq(▼詳しいルールについては、管理者が指定するものに従ってください。); }

	# ボーナス
	#elsif($type =~ /FAST/){
		$guide = qq(
		<strong class="red">スレッドの重複</strong>や、新規投稿のルール違反にご注意下さい。
		);
	#}

	# 最終投稿ガイド(普通)
	#else{
	#$guide = qq(投稿先は <a href="./" class="red">$title</a>で間違いありませんか？<br$xclose>
	#まだ何か分からない気がする場合は、<a href="form.html">新規投稿の説明</a>や<a href="ruleform.html">ローカルルールの説明</a>に戻って、文章を読み直してください。);
	#}


# 類似記事を自動検索
my($auto_find_line) = Mebius::BBS::AutoFindThread(undef,$in{'sub'});

if($main::postflag && !$main::in{'sub'}){ main::error("題名を入力してください。"); }

# HTML
$print .= qq(
<h1$main::kstyle_h1>新規投稿 ($title)</h1>
<div class="lastform_guide">$guide</div>
$auto_find_line
<h2$main::kstyle_h2>投稿フォーム</h2>
);

	# 投稿フォーム
	if($kflag){
		require "${int_dir}k_form2.pl";
		($print) .= bbs_thread_form_mobile("new");
	}


$print .= qq($resform);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

package Mebius::BBS;
use strict;

#-----------------------------------------------------------
# 自動検索
#-----------------------------------------------------------
sub AutoFindThread{

# 宣言
my($type,$subject) = @_;
my($index_handler,$line,@index_line,$i_index,$max_view);

my $plustype_autofind;
	if($main::kflag){ $plustype_autofind .= qq( Mobile-view); }
	else{ $plustype_autofind .= qq( Desktop-view); }

require "${main::int_dir}part_indexview.pl";
my($line,$hit) = Mebius::BBS::IndexFind("Now-file Subject-search $plustype_autofind",$subject,10);

		# インデックスの整形
		if($line){
				if($main::kflag){
					$line = qq(
					<h2$main::kstyle_h2>類似記事</h2>
					$line
					);
				}
				else{
					$line = qq(
					<h2$main::kstyle_h2>類似記事</h2>
					<table cellpadding="3" summary="記事一覧" class="table2">
					<tr><th class="td0">印</th><th class="td1">題名</th><th class="td2">名前</th><th class="td3">最終</th><th class="td4"><a name="go"></a>返信</th></tr>
					$line
					</table>
					);
				}
		}

return($line);

}


#-----------------------------------------------------------
# レス投稿してから～時間以内でないと、新規投稿できない
#-----------------------------------------------------------
sub PostAfterResCheck{

# 宣言
my($type) = @_;
my($error);

	if($main::bbs{'concept'} =~ /(Res|Post)-after-res-(\d+)/){
		my $judge_type = $1;
		my $limit_hour = $2;
		require "${main::int_dir}part_history.pl";
		my($lastrestime) = main::get_reshistory("Get-lastres-time My-file",undef,undef,$main::moto);

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($lastrestime)); }

		if($lastrestime eq "" || time >= $lastrestime + ($limit_hour*60*60)){
			$error = qq(この掲示板では、レスを投稿してから$limit_hour時間以内でないと、新規投稿できません。詳しくは<a href="rule.html">ローカルルール</a>をご確認ください。);
		}
	}

	# エラーの扱い
	if($error){
		if($type =~ /Error-view/){ main::error("$error"); }
		else{ $main::e_com .= qq(▼$error<br$main::xclose>); }
	}

return($error);

}

1;
