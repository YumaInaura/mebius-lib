
use strict;
package main;

#-----------------------------------------------------------
# サブ記事モードの基本設定
#-----------------------------------------------------------
sub init_option_bbs_subbase{


my($init_directory) = Mebius::BaseInitDirectory();
our($moto);

	our $subtopic_link = undef;
	our $subtopic_mode = 1;
	our $style = '/style/sub1.css';
}

#-----------------------------------------------------------
# サブ記事 基本処理
#-----------------------------------------------------------
sub thread_sub_base{

my($MAIN_FILE,$SUB_FILE);
my($init_directory) = Mebius::BaseInitDirectory();
our(%in,$xclose,$moto,$kflag);

# 各種定義
#$nomemo_flag = 1;
our $concept .= qq( NOT-KR);
our $resedit_mode = 0;

# CSS定義
our $css_text .= qq(
textarea{background-color:#f2f2ff;border:solid 1px #99b;}
li{line-height:2.0em;}
.bbs_border{border-style:groove;border-width:1px;}
);

# メイン記事を読み込み
my($main_thread) = Mebius::BBS::thread_state({ Auto => 1 , MainThread => 1 },$in{'no'});
our($no,$sub,$mainres,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$dd5,$dd6,$dd7,$dd8,$juufuku_com,$dd10) = split(/<>/,$main_thread->{'all_line'}->[0]);
	if(!$main_thread->{'f'}){ http404(); }

my $bbs_path = Mebius::BBS::Path->new($main_thread);
my $thread_url = $bbs_path->thread_url_adjusted();

our $mainsub = $sub;
our $sub = "$sub [ サブ ]";

# 記事データ読み込み
my($sub_thread) = Mebius::BBS::thread_state({ Auto => 1 , SubThread => 1 },$in{'no'});
our($subno,$subsub,$res,$subkey,$subres_pwd,$t_res,undef,$subd_password,$subdd1,$subsexvio,$subdd3,$subdd4,$subdd5,$subdd6,$subdd7,$subdd8,$juufuku_com,$subdd10) = split(/<>/, $sub_thread->{'all_line'}->[0]);

	# レスがない場合広告を消し、404エラー
	if($res <= 0){ our $noads_mode = 1; our $noindex_flag = 1; } # &http404();

	# 過去ログで、サブ記事のレスも無い場合
	if($key eq "3" && !$res){ &error("このサブ記事は過去ログで、レスがありません。"); }

	# メイン記事へのリンク
	if(!$mainres){ $mainres = 0; }
our $move_mainres = qq(<span class="comoji">切替： <a href="$thread_url" class="red">メイン記事</a> <a href="$thread_url#S$mainres" class="red">($mainres)</a> / <span class="green">サブ記事($res)</span></span> ) if($mainres);

# 最新の書き込み
my($lastres_link);
	if($in{'r'} eq "" && $in{'No'} eq "" && $res >= 1){ $lastres_link = qq( - <a href="#S${res}">▼最終レス($res)</a>); }

	# タイトル定義
	if($kflag){
		require "${init_directory}k_view.pl";
		thread_set_title_mobile();
	}
	else{
		thread_set_title({ SubThread => 1 },$main_thread);
	}

$main_thread,$sub_thread;

}


#-----------------------------------------------------------
# No.0 の表示内容
#-----------------------------------------------------------
sub thread_get_subzero{

my($line);
my $use_thread = shift;
our($mainres,%in,$moto,$sub,$ads_up,$ads_rup,$mainsub,$res,$guide_url,$lastres_link);
my $bbs_path = Mebius::BBS::Path->new($use_thread);
my $thread_url = $bbs_path->thread_url_adjusted({ MainThread => 1 });

$line = qq(
<div class="d"> 
<strong><span class="vsub">$sub </span> </strong> 
<a href="$thread_url" class="red">●メイン記事</a> <a href="$thread_url#S$mainres" class="red">($mainres)</a> / <span class="green">○サブ記事($res)</span>);

my($request_url_encoded) = Mebius::request_url_encoded();

$line .= qq(
$lastres_link
<br><br>
<ul style="margin-bottom:1.5em;">
<li><a href="/_$moto/$in{'no'}.html">$mainsub</a> のサブ記事です。感想、コメントなどにご利用ください。
<li><strong class="red">メイン記事と全く関係のない雑談</strong>はご遠慮ください。
<li><a href="${guide_url}%A5%B5%A5%D6%B5%AD%BB%F6%A3%D1%A1%F5%A3%C1">他、詳しい使いかたはサブ記事ガイドをご覧ください。</a>
</ul>
$ads_up$ads_rup
<br class="clear">
</div>
);

return($line);

}


#-----------------------------------------------------------
# No.0 の表示内容 （携帯版）
#-----------------------------------------------------------
sub thread_get_ksubzero{

my($line);
our($xclose,$moto,%in,$mainsub,$ktext_up);

$line = qq(<hr$xclose><a name="S0" id="S0"></a>これは”<a href="/_$moto/$in{'no'}.html">$mainsub</a>”のサブ記事です。$ktext_up);

return($line);


}



1;
