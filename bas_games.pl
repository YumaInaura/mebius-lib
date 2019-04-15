
package Mebius::Games;
use strict;

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub init_start_games{

$main::sub_title = "メビゲー";
$main::head_link2 = qq(&gt; <a href="/_games/">メビゲー</a>);

}

#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------
sub start_games{

# スクリプト定義
our $script = "/_games/";
my($redirect_uri);


	$main::head_link1 = qq( &gt; <a href="http://aurasoul.mb2.jp/">通常版</a> | <a href="http://mb2.jp/">娯楽版</a>);
	$main::head_link1 = 0;

	# 携帯アイテムを取得
	if($main::in{'k'}){ main::kget_items(); }

	# アクセス振り分け
	if($main::in{'k'} eq "" && $main::device_type eq "mobile" && $main::requri && $main::requri !~ /imode/ && !$main::postflag){
		Mebius::Redirect("","http://$main::server_domain/imode$main::requri");
	}

	# アクセス振り分け
	if($main::in{'k'} && $main::device_type eq "desktop" && $main::requri && $main::requri =~ /imode/ && !$main::postflag){
		$redirect_uri = $main::requri;
		$redirect_uri =~ s|imode/||g;
		Mebius::Redirect("","http://$main::server_domain$redirect_uri");
	}


	# モード振り分け
	if($main::in{'game'} eq ""){ &Index(); }
	#if($main::in{'game'} eq "dungeon"){ require "${main::int_dir}games_dungeon.pl"; Mebius::Dungeon::Mode(); }
	#else{ main::error("ページが存在しません。"); }
	main::error("ページが存在しません。[gms]");

	exit;

}


#-----------------------------------------------------------
# ゲームの基本設定を取得
#-----------------------------------------------------------
sub Init{

	# Docomoの utn を一括定義
	our $utn2 = undef;
	if($main::k_access eq "DOCOMO"){ $utn2 = qq( utn="utn"); }

return(undef,undef,$utn2);

}



#-----------------------------------------------------------
# インデックス
#-----------------------------------------------------------
sub Index{

$main::head_link2 = qq(&gt; メビゲー);


# HTML
my $print = qq(
<h1>メビゲー</h1>
<ul>
<li><a href="dungeon/">ダンジョンワーク</a></li>
<li><a href="http://aurasoul.mb2.jp/gap/ff/ff.cgi">メビリン・アドベンチャー</a></li>
</ul>
);


Mebius::Template::gzip_and_print_all({},$print);

exit;



}



1;
