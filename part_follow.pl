
use strict;
use Mebius::Follow;
package main;
use Mebius::Export;


#-----------------------------------------------------------
# 掲示板の手動フォロー状況を判定
#-----------------------------------------------------------
sub check_followed{

# 宣言
my($type,$moto) = @_;
my($followed_flag);

	# リターン
	if($main::cfollow eq ""){ return(); }
	if($moto eq ""){ return(); }

	# Cookie内容から、手動フォローを展開
	foreach(split(/ /,$main::cfollow)){
		my($type2,$value) = split(/=/,$_);
		if($type2 eq "bbs"){
			if($value eq $moto){ $followed_flag = 1; }
		}
	}

# リターン
return($followed_flag);

}

#-----------------------------------------------------------
# フォロー登録画面 
#-----------------------------------------------------------
sub form_follow{

# 局所化
my($input_delete,$submit_bottun,$delete_link,$please_link,@BCL);
my($max_follow,$max_follow_pertype) = Mebius::BBS::init_follow();
my($basic_init) = Mebius::basic_init();
our($script,$xclose,$title,$head_title,$cfollow,$moto,$realmoto,$sikibetu,$kinputtag);

# タイトル定義
my $sub_title = "$head_title のフォロー";
push @BCL , " &gt; フォロー";

# CSS定義
$main::css_text .= qq(
div.abount{line-height:1.4em;}
ul{margin:1em 0em;}
ul.second{font-size:90%;border:solid 1px #f00;padding:1em 2.5em;}
.follow_start{font-size:110%;}
.follow_delete{color:#555;}
a.cancel{font-size:90%;}
);


# 各種テキスト
	if(Mebius::alocal_judge()){ $delete_link =  qq(<br$xclose><br$xclose>　<a href="$script?type=follow&amp;work_type=delete">→フォローを解除</a><br$xclose>); }
	if($cfollow eq ""){ $please_link = qq(<li>よく分からない場合は、<strong class="red">試しにフォローしてみてください！ </strong></li>); }
	if(Mebius::Switch::stop_bbs()){
		$submit_bottun = qq(　<input type="button" value="$head_title へのフォローを追加する" class="follow_start" disabled$xclose>);
	} else {
		$submit_bottun = qq(　<input type="submit" value="$head_title へのフォローを追加する" class="follow_start"$xclose>);
	}

	foreach(split(/ /,$cfollow)){
		my($type,$value) = split(/=/,$_);
			if($type eq "bbs" && $value eq $moto){
				$submit_bottun = qq(<span class="red">※この掲示板は既にフォロー中です。</span> <input type="submit" value="$head_title のフォローを解除する" class="follow_delete"$xclose>);
				$input_delete = qq(<input type="hidden" name="work_type" value="delete"$xclose>);
			}
	}


# HTML
my $print = qq(
<h1>フォロー | <a href="./">$title</a></h1>
<form action="$script" method="post"$sikibetu>
<div>
<input type="hidden" name="type" value="follow"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
$kinputtag
$input_delete
<div class="abount">
$submit_bottun
<ul>
<li>気になる掲示板は<strong class="red">フォロー</strong>して、最新データ ( レス、新記事 ) をゲットしましょう。</li>
<li>フォローは <strong class="red">最大$max_follow種類</strong> まで登録できます。</li>
<li>手動でフォローした場合は、好きな掲示板だけがフォローとして表\示されます。フォローがない場合は、投稿履歴から自動でフォローを取得します。</li>
$please_link
</ul>

<ul class="second">
<li>フォロー状況は時間経過や環境により消えてしまうこともあります。<a href="$basic_init->{'auth_url'}">アカウントにログイン</a>するとフォロー状況がサーバーに記録されるため、消えることがなくなります。</li>
</ul>

$delete_link
</div>
</div>
</form>
);


Mebius::Template::gzip_and_print_all({ title => $sub_title , BCL => \@BCL },$print);

exit;

}

#-----------------------------------------------------------
# フォローを追加 / 削除
#-----------------------------------------------------------
sub do_follow{

# 局所化
my($type) = @_;
my($file,$i,@keep_follow,$ppfollow,$work_type);
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
our($script,$jump_url,$jump_sec,$no_headerset,$moto,$title,$cfollow,$head_title);

# 基本設定を取得
my($max_follow,$max_follow_pertype) = Mebius::BBS::init_follow();

# クッキーの二重セットを禁止
$no_headerset = 1;

# GET送信を禁止
#if(!$postflag){ &error("GET送信は出来ません。"); }

# ファイル定義
$file = $my_account->{'id'};

	# 各種エラー
	if(!$ENV{'HTTP_COOKIE'}){ &error("この環境では利用できません。"); }

# 秘密板の場合
#if($secret_mode && !$idcheck){
#&error("この掲示板でフォロー機能\を使うには、<a href=\"${auth_url}\">アカウントにログイン</a>してください。");
#}

	# 掲示板を追加
	if($param->{'work_type'} ne "delete"){
			if($type eq "bbs"){ push(@keep_follow,"bbs=$moto"); }
	}

	# リストを展開
	foreach(split(/ /,$cfollow)){
			if($_ eq "off" && $param->{'work_type'} eq ""){ next; }
		$i++;
		my($follow_type,$value) = split(/=/,$_);
			if($type eq $follow_type && $value eq $moto && !Mebius::alocal_judge()){ next; }
			if($type eq $follow_type && $value eq $moto && $param->{'work_type'} eq "delete"){ next; }
			if($i < $max_follow){ push(@keep_follow,"$_"); }
	}
$cfollow = "@keep_follow";
if($cfollow eq ""){ $cfollow = "none"; }

# ジャンプ先
$jump_url = "./";
	if(Mebius::alocal_judge()){ $jump_url = "$script"; }
$jump_sec = 1;

# アクセスログ
if($param->{'work_type'} ne "delete"){ &access_log("FOLLOW"); }

# タイトル定義
my $sub_title = "$head_title のフォロー";
my @BCL = (" &gt; フォロー");

# クッキーセット
Mebius::Cookie::set_main({ follow => $cfollow },{ SaveToFile => 1 });

# リダイレクト
#my $backurl = "http://$server_domain/_$moto/";
#my ($backurl_enc) = Mebius::Encode("",$backurl);
#if($param->{'work_type'} eq "delete" && !Mebius::alocal_judge()){ #Mebius::Redirect("","http://$server_domain/_main/?mode=my&backurl=$backurl_enc");
#}


# 表示
$work_type = qq(追加);
if($param->{'work_type'} eq "delete"){ $work_type = qq(解除); }

my $print = qq(<a href="$script">$title</a>のフォローを$work_typeしました。（<a href="$jump_url">→戻る</a>）);

Mebius::Template::gzip_and_print_all({ title => $sub_title , BCL => \@BCL },$print);

exit;

}


package Mebius::BBS;


#-----------------------------------------------------------
# フォローの基本設定
#-----------------------------------------------------------
sub init_follow{

# 宣言
my($type) = @_;
my($my_use_device) = Mebius::my_use_device();

# フォローを登録できる最大数
my $max_follow = 5;

# １個のターゲット（掲示板など）からフォロー状況を何行まで取得するか
my $max_follow_pertype = 5;

# リターン
return($max_follow,$max_follow_pertype);

}



1;
