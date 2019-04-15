
use Mebius::BBS;
use Mebius::Page;

package main;
use strict;

#-------------------------------------------------
#  基本調整 - strict
#-------------------------------------------------
sub init_start_bbs{

# 宣言
my($basic_init) = &Mebius::BasicInit();
my($init_directory) = &Mebius::BaseInitDirectory();
my($server_domain) = &Mebius::ServerDomain();
my($type) = @_;
my($eval,$original_moto);
our(@color,$menu1,$menu2,$p_page,$pfirst_page,$kfirst_page,$m_max,$i_max,$kpage,$new_wait);
our($upload_url,$upload_dir,$realmoto,$moto,$logdir,$category,$nowfile,$pastfile,$home,$hometitle,$concept);
our($backup_dir,$alocal_mode,$secret_mode,$bbs_redirect,%in);

# 文字色
(@color) = &Mebius::Init::Color();

# 各種設定
$menu1 = 30;		# 現行ログ、１メニューあたりの最大記事表示数
$menu2 = 100;		# 過去ログ、１メニューあたりの最大記事表示数
$i_max = 300;		# 掲示板１個あたりの、最大記事数
($p_page,$pfirst_page) = &Mebius::Page::InitPageNumber("Desktop-view"); # ページ分割設定を取得
($kpage,$kfirst_page) = &Mebius::Page::InitPageNumber("Mobile-view"); # ページ分割設定を取得
$m_max = 2000;		# 記事１個あたりの、最大レス登録個数
$new_wait = 72;		# 新規投稿の待ち時間（～時間）

# 投稿の基本設定
our $wait = 4;				# レスの基本待ち時間
our $max_msg = 6000;		# レスの最大文字数
our $min_msg = 10;			# レスの最小文字数
our $new_max_msg = 9000;	# 新規投稿の最大文字数
our $new_min_msg = 100;		# 新規投稿の最小文字数
our $ngbr = 300;			# 投稿時の最大改行個数

	# ローカル設定 (現在は不使用?)
	#if(&Mebius::AlocalJudge() && !$main::admin_mode){
	#	$backup_dir = "./_backup_home/";
	#}

# $motoを定義
$original_moto = $moto;
	if($type =~ /Admin-mode/){}
	elsif($realmoto =~ /^sc([a-z0-9]+)$/){ } # 秘密板
	else{
		$moto = $in{'moto'};
			if($moto =~ /[^0-9a-z]/){ &error("掲示板の指定が変です。"); }
		$realmoto = $moto;
		$moto =~ s/^sub//;
			if($moto eq ""){ &error("掲示板を指定してください。"); }
	}

# 新設定ファイル(個別設定)を読み込み
our(%bbs) = &main::InitBBS("Get-global Get-hash",$moto);

	# 掲示板が設定されていない場合
	if(!$bbs{'alive'}){
			# BBS.pm の中に配列がある場合は、掲示板を自動作成
			if($main::myaccount{'admin_flag'}){
				my(%all_bbs_hash) = &Mebius::BBS::BBSNameAray("Get-all-category");
					if($all_bbs_hash{$moto}){
						&Mebius::Fileout("Allow-empty Deny-f-file-return",$bbs{'file'});
						&Mebius::Mkdir(undef,$bbs{'data_directory'});
					}
					else{ &main::error("この掲示板は設定されていません。"); }
			}
			# 設定されていない掲示板のエラーを出す
			else{ &main::error("この掲示板は設定されていません。"); }
	}

	# 閉鎖中の掲示板
	if($concept =~ /Admin-only/ && $type !~ /Admin-mode/){ &main::error("この掲示板は設定されていません。"); }
	if($concept =~ /BBS-CLOSE/){ &main::error("この掲示板は閉鎖中です。","410 Gone"); }

	# ログインモード
	if($concept =~ /Mode-login/){
		require "${init_directory}part_login.pl";
		&Mebius::Login::Logincheck("",$realmoto);
	}

	# 秘密板
	if($secret_mode){
			if($original_moto !~ /^sc([a-z0-9]+)$/ && !$alocal_mode){ &error("この掲示板は存在しません。"); }
			if($type =~ /Admin-mode/ && $main::admy{'rank'} < $main::master_rank && $moto ne "sc$main::admy{'second_id'}"){ &main::error("この掲示板は管理できません。"); }

		require "${init_directory}def_secret.pl";
		&scbase();
	}

	# アップロード可能な場合
	if($main::bbs{'concept'} =~ /Upload-mode/){
		require "${init_directory}part_upload.pl";
		($upload_url,$upload_dir) = &init_upload("",$realmoto);
	}

# 掲示板の移転
if($bbs_redirect =~ /http:/){ require "${init_directory}part_movebbs.pl"; &movebbs_redirect("",$bbs_redirect); }

	# サブ記事モードの場合、設定を追加
	if($realmoto =~ /^sub/){ require "${init_directory}part_subview.pl"; &init_option_bbs_subbase(); }

	# 掲示板独自の設定 ( 2 )
	if($type !~ /Admin-mode/){
			if(!$home){ $home = "http://$server_domain/"; }
			if($server_domain eq "mb2.jp" || $home eq "http://mb2.jp/"){ $hometitle = "メビウスリング娯楽版"; }
			if($server_domain eq "mb2.jp"){ $home = "http://mb2.jp/"; }
	}


	# 現行ログなど設定
	if($init_directory && $moto){
			if($logdir eq ""){ $logdir = $bbs{'thread_log_directory'}; }
			if($nowfile eq ""){ $nowfile = "$bbs{'data_directory'}_index_${moto}/index_${moto}.log"; }
			#if($nowfile eq ""){ $nowfile = "${init_directory}${moto}_idx.log"; }
			if($pastfile eq ""){ $pastfile = "$bbs{'data_directory'}_index_${moto}/${moto}_pst.log"; }
			if($main::newpastfile eq ""){ $main::newpastfile = "${init_directory}_bbs_index/_${main::moto}_index/${main::moto}_allindex.log"; }
			if($category eq ""){ $category = "nocate"; }
	}

	# CSS追加
	push(@main::css_files,"bbs_all");

# 著作権表示
our $original_maker = qq(<a href="http://www.kent-web.com/" rel="nofollow">配布-WebPatio</a>);
$original_maker .= qq(┃<a href="http://aurasoul.mb2.jp/">改造-$basic_init->{'top_level_domain'}</a>);

# 現在のフォロー状況を判定
require "${init_directory}part_follow.pl";
our($followed_flag) = &check_followed("",$moto);

}

#-----------------------------------------------------------
# 処理スタート - strict
#-----------------------------------------------------------
sub start_bbs{

# 宣言
our(%in,$mode,$submode1,$int_dir);

	# モード振り分け
	if($mode eq "view"){
		if($in{'r'} eq "support"){ require "${int_dir}part_support.pl"; &bbs_support(); }
		elsif($in{'r'} eq "data"){ require "${int_dir}part_data.pl"; &bbs_view_data(); }
		elsif($in{'r'} eq "memo"){ require "${int_dir}part_memo.pl"; &bbs_memo(); }
		else{ require "${int_dir}part_view.pl"; &bbs_view_thread(); }
	}
	elsif($mode eq "kview" || $mode eq "kindex" || $mode eq "kfind" || $mode eq "kform" || $mode eq "krule" || $mode eq "kruleform") {

		# デスクトップ版のURLとまとめる ( リダイレクト )
		&Mebius::BBS::UnifyMobileURL();

		#if($in{'r'} eq "support"){ require "${int_dir}part_support.pl"; &bbs_support(); }
		#elsif($in{'r'} eq "data"){ require "${int_dir}part_data.pl"; &bbs_view_data(); }
		#elsif($in{'r'} eq "memo"){ require "${int_dir}part_memo.pl"; &bbs_memo(); }
		#else{ require "${int_dir}k_view.pl"; &bbs_view_thread_mobile(); }
	}
	if($mode eq "support"){ require "${int_dir}part_support.pl"; &bbs_support(); }
	#elsif($mode eq "kindex") { require "${int_dir}k_indexview.pl"; &view_kindexview("VIEW"); }
	elsif($mode eq "form" || $mode eq "ruleform") { require "${int_dir}part_newform.pl"; &bbs_newform(); }
	#elsif($mode eq "kfind") { require "${int_dir}k_find.pl"; &bbs_find_mobile(); }
	elsif($submode1 eq "kpt"){ require "${int_dir}k_past.pl"; &bbs_view_past_mobile(); }
	elsif($submode1 eq "feed"){ require "${int_dir}part_feed.pl"; &bbs_view_feed(); }
	elsif($submode1 eq "ranking"){ require "${int_dir}part_handle_ranking.pl"; &Mebius::BBS::HandleRankingIndex(); }
	elsif($mode eq "rule") { require "${int_dir}part_rule.pl"; &bbs_rule_view(); }
	elsif($mode eq "tmove") { require "${int_dir}part_tmove.pl"; &bbs_tmove(); }
	elsif($mode eq "cermail") { require "${int_dir}part_cermail.pl"; &Mebius::Email::CermailStart(); }
	elsif($mode eq "Nojump") { require "${int_dir}part_Nojump.pl"; &bbs_number_jump(); }
	elsif($mode eq "resedit") { require "${int_dir}part_resedit.pl"; &thread_resedit(); }
	elsif($mode eq "mylist") { require "${int_dir}part_mylist.cgi"; &bbs_mylist(); }
	elsif($mode eq "resdelete") { require "${int_dir}part_resdelete.pl"; &bbs_res_selfdelete(); }
	elsif($mode eq "member") { require "${int_dir}part_memberlist.pl"; &bbs_memberlist(); }
	elsif($mode eq "scmail") { require "${int_dir}part_scmail.pl"; &bbs_scmail(); }
	elsif($mode eq "find" || $mode eq "oldpast") { require "${int_dir}part_indexview.pl"; &bbs_view_indexview(); }
	elsif($submode1 eq "past") { require "${int_dir}part_pastindex.pl"; &Mebius::BBS::PastIndexView("Select-BBS-view"); }
	elsif($mode =~ /^(random|link|my)$/) { require "${int_dir}part_etcmode.pl"; &etc_mode(); }
	elsif($mode eq "regist" || $mode eq "regist_resedit"){ require "${int_dir}part_regist.pl"; &bbs_regist(); }
	else{ require "${int_dir}part_indexview.pl"; &bbs_view_indexview(); }

exit;

}


1;
