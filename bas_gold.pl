
# パッケージ宣言
package Mebius::Goldcenter;
use strict;

# -------------------------------------------
# 基本設定
# -------------------------------------------
sub init_start_gold{

# 全変数をリセット
reset 'a-z';

# 宣言
my($script_mode,$gold_url,$title) = &init();

# メイン設定
$main::head_link1 = 0;
$main::head_link1 = qq(&gt; <a href="http://$main::server_domain/">$main::server_domain</a> );

# タイトル設定
$main::sub_title = qq($title);
$main::head_link2 = qq(&gt; <a href="$gold_url">金貨センター</a> );

# CSS定義
$main::css_text .= qq(
h1{color:#220;}
h2{color:#220;background:#ee8;border:solid 1px #cc0;padding:0.35em 0.7em;font-size:100%;}
h3{color:#220;font-size:95%;background:#ffc;border:solid 1px #990;width:30%;padding:0.2em 0.5em;}
ul{margin:0.8em 0em;}
);

# CSS定義 ( 金貨が使えない場合 )
	if(!$main::callsave_flag){
$main::css_text .= qq(h2,h3{background:#eee;border:solid 1px #999;});
	}

# 検索ボックスで自分を検索しない
$main::nosearch_mode = 1;

# 外部CSS
$main::style = "/style/orange.css";



}

#-----------------------------------------------------------
# パッケージの基本設定
#-----------------------------------------------------------
sub init{

# 設定
my $script_mode = "";	# "TEST" でテストモード
my $gold_url = "/_gold/";	# 金貨センターのURL
my $title = "金貨センター";	# タイトル

# テストモードの制限
if($main::myadmin_flag >= 5 || $main::alocal_mode){ $script_mode = ""; } # "TEST"

# リターン
return($script_mode,$gold_url,$title);

}

#-----------------------------------------------------------
# 必要な金貨量の設定
#-----------------------------------------------------------
sub get_price{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my(%price);

# 各サービスに必要な金貨を定義
%price = (
"cancel_newwait" => 100, # 新規待ち時間をなくす
);

# リターン
return(%price);

}

#-------------------------------------------------
# スタート - スクリプト
#-------------------------------------------------
sub start_gold{

# 宣言
my($script_mode,$gold_url,$title) = &init();

	# 携帯版
	if($main::device_type eq "mobile"){
		main::kget_items();
	}

	# ○モード振り分け
	if($main::submode1 eq ""){ &index(); }

	# 新規投稿の待ち時間を無くす
	elsif($main::submode1 eq "cancel_newwait"){ &cancel_newwait(); }

	# 賭け金貨
	elsif($main::submode1 eq "gyamble1" && $main::postflag){ &gyamble1("",$main::in{'chaise_gold'}); }
	elsif($main::submode1 eq "gyamble1" && !$main::postflag){ &form_gyamble1("Indexview Winlose-get Page-me",$main::in{'chaise_gold'}); }

	# 他のユーザーに金貨を渡す
	elsif($main::submode1 eq "present_gold"){
			
		# 管理者として金貨を授与
		if($main::myadmin_flag >= 1 && $main::in{'gave_gold'}){
		&present_gold("GAVE",$main::in{'account'},$main::in{'present_gold'});
		}
		# ユーザーとして金貨をプレゼント
		else{
		&present_gold("PRESENT",$main::in{'account'},$main::in{'present_gold'});
		}
	}

	# アイテムショップ
	elsif($main::submode1 eq "item"){ &item(); }
	
	# モード定義がない場合
	else{ main::error("ページが存在しません。"); }

exit;

}

#-----------------------------------------------------------
# インデックス
#-----------------------------------------------------------
sub index{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($line_guide,$line_record_spend,$form_cancel_newwait,$form_present_gold,$form_gyamble1);
my($navi_links);

# CSS定義
$main::css_text .= qq(
div.guide{line-height:1.4em;}
div.index_flow{text-align:right;}
div.navilinks{word-spacing:0.5em;}
);


# 説明
$line_guide = qq(<li>アカウントにログインしていたり、一部の携帯電話では、金貨センターが利用できます。</li>);
	if($main::callsave_flag){ $line_guide .= qq(<li>いまのあなたは、金貨センターを<strong class="red">利用できます。</strong></li>); }
	else{ $line_guide .= qq(<li>いまのあなたは、金貨センターを<strong class="red">利用できません。</strong><a href="$main::auth_url?backurl=$main::selfurl_enc">アカウント</a>にログイン(または新規登録)してください。</li>); }
	if($main::callsave_flag){
$line_guide .= qq(<li>金貨はサーバーごとに記録されます。いまのサーバーは $main::server_domain です。</li>);
	}
$line_guide .= qq(<li class="red">注意！　サイト内でのルール違反（文字数稼ぎ、文字の羅列、無断転載など）があった場合、<strong>「金貨の消失」「投稿制限」などのペナルティを加えさせていただく場合があります。</strong></li>);

# 説明の整形
$line_guide = qq(
<h2>説明</h2>
<div class="guide">
<ul>$line_guide</ul>
</div>
);


# 各種フォームを取得
($form_cancel_newwait) = &form_cancel_newwait();
($form_gyamble1) = &form_gyamble1();
($form_present_gold) = &form_present_gold();

# 金貨の使用記録をゲット、整形
	if($main::in{'viewmax'}){ ($line_record_spend) = &record_spend("VIEW",""); }
	else{ ($line_record_spend) = &record_spend("VIEW","",5); }
	if($line_record_spend){
		if($main::in{'viewmax'}){ $line_record_spend = qq(<h2 id="SPEND_RECORD">金貨の使用記録</h2>\n$line_record_spend); }
		else{
$line_record_spend = qq(<h2 id="SPEND_RECORD"><a href="./?viewmax=1$main::backurl_query_enc#SPEND_RECORD">金貨の使用記録</a></h2>\n$line_record_spend);
$line_record_spend .= qq(<div class="index_flow"><a href="./?viewmax=1$main::backurl_query_enc#SPEND_RECORD">→続きを表\示する</a></div>);
		}
	}

# タイトル定義
$main::head_link2 = qq( &gt; $title);
$main::canonical = $gold_url;


# ドメインリンクを取得
my($domain_links) = Mebius::Domainlinks("",$main::server_domain,"_gold/");

# ナビゲーションリンクを定義
	if(!$main::kflag){
my($backurl_link) = ($main::backurl_link) if($main::backurl !~ /$gold_url/);
$navi_links = qq(
<div class="navilinks">
<a href="/">TOPページ</a> $backurl_link 
あなたの金貨：<strong class="red">$main::cgold枚</strong> <img src="/pct/icon/gold1.gif" alt="金貨"$main::xclose>
</div>
);
	}

# HTML
my $print = qq(
<h1>$title / $domain_links</h1>
$navi_links

$line_guide
<h2 id="SPEND_GOLD">金貨を使う</h2>
$form_present_gold
$form_gyamble1
$form_cancel_newwait
<h3>レス待ち時間の優遇</h3>
金貨が<strong class="red">プラス</strong>だと、レス投稿のチャージ時間が短めになります。<br$main::xclose>
逆に<strong class="blue">ある程度マイナス</strong>だと、チャージ時間が長めになります。（自動反映）
$line_record_spend
<h2>金貨ランキング</h2>
<a href="${main::main_url}rankgold-p-1.html">→金貨ランキングはこちらです。</a>
);

Mebius::Template::gzip_and_print_all({},$print);


exit;

}


#-----------------------------------------------------------
# 金貨の使用記録を取得 / 更新
#-----------------------------------------------------------
sub record_spend{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my($type,$message,$maxview_line) = @_;
my(@line,$file,$viewline,$i,$newhandle);
my($maxrecord_line) = (100);

# IDを取得
my($encid) = main::id();

# ファイルを定義
$file = "${main::int_dir}_backup/gold_spend.log";

# 記録する筆名
	if($type =~ /RENEW/){
$newhandle = $main::chandle;
		if($newhandle eq ""){ $newhandle = $main::pmname; }
		if($newhandle eq ""){ $newhandle = qq(名無し); }
	}

# 追加する行
	if($type =~ /RENEW/){
push(@line,"1<>$newhandle<>$message<>$main::pmfile<>$main::host<>$main::agent<>$main::date<>$main::time<>$main::cnumber<>$encid<>\n");
	}

# ファイルを開く
open(GOLD_RECORD_IN,"<$file");
	if($type =~ /RENEW/){ flock(GOLD_RECORD_IN,1); }
while(<GOLD_RECORD_IN>){
chomp;
my($key2,$handle2,$message2,$account2,$host2,$agent2,$date2,$time2,$cnumber2,$encid2) = split(/<>/);
$i++;
	if($i > $maxrecord_line){ next; }
	if($type =~ /RENEW/){ push(@line,"$_\n"); }
	if($type =~ /VIEW/ && ($i <= $maxview_line || !$maxview_line)){
		if($account2){ $handle2 = qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>); }
	$viewline .= qq(<li>$handle2 <i>★$encid2</i>　さんが $message2 ( $date2 )</li>\n);
	}
}
close(GOLD_RECORD_IN);

# 閲覧のみの場合、リターン
	if($type =~ /VIEW/){
		if($viewline){ $viewline = qq(<ul>$viewline</ul>); }
return($viewline);
	}

# ファイルを更新する
	if($type =~ /RENEW/){ Mebius::Fileout("",$file,@line); }

# リターン
return();

}

#-----------------------------------------------------------
# 金貨を計算
#-----------------------------------------------------------
sub cash_check{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my($type,$price) = @_;
my($line,$disabled);

	# 値段が空の場合
	if($type =~ /REGIST/){
		if($price eq ""){ main::error("値段がカラです。"); }
		if($price =~ /\D/){ main::error("半角数字のみ指定できます。"); }
	}

# アクセス制限
if($type =~ /REGIST/){ main::axscheck("ACCOUNT"); }

# メソッド制限
if(!$main::postflag && $type =~ /REGIST/){ main::error("GET送信は出来ません。"); }

# 値段の計算
	if($main::cgold < $price){
		if($type =~ /REGIST/){
main::error("金貨が足りないため、実行できません。 $main::cgold枚 / $price枚");
		}
		else{
$line = qq(<span class="alert">金貨が足りません。</span>);
$disabled = $main::parts{'disabled'};
		}
	}

# 実行できない環境
	if(!$main::callsave_flag){
		if($type =~ /REGIST/){
main::error("この環境では実行できません。アカウントにログインしてください。");

		}
		else{
$line = qq(<span class="alert">この環境では実行できません。</span>);
$disabled = $main::parts{'disabled'};
		}
	}


# リターン
return($line,$disabled);

}

#-----------------------------------------------------------
# 記録用の筆名を取得
#-----------------------------------------------------------
sub get_handle{

# 宣言
my($type) = @_;
my($handle);

# 記録する筆名を定義
$handle = $main::chandle;
if($handle eq ""){ $handle = $main::pmname; }
if($handle eq ""){ $handle = qq(名無し); }
if($main::pmfile){ $handle = qq(<a href="${main::auth_url}$main::pmfile/">$handle</a>); }

# リターン
return($handle);

}

1;
