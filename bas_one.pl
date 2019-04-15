
#-----------------------------------------------------------
# 基本設定
#-----------------------------------------------------------
sub init_start{

$style = "/style/bas.css";
$maxData = 50000;

# 公式カテゴリ
@base_category = (
'人生のヒント=日常のヒント、人生のヒントなど。',
'教訓=日々で得た教訓、人生のヒントなど。',
'座右の銘=お気に入りの言葉。',
'キャッチフレーズ=オリジナルのキャッチフレーズ。',
'詩=一行詩などいかが？',
'哲学=哲学的なこと。'
);

#'反省=反省を明日に生かす。',
#'発見=日々の中で見つけたこと。',

#$head_link1 = 0;
$head_link2 = 0;
$nosearch_mode = 1;

$sub_title = "マイログ";
$title = "マイログ";
$head_link2 = qq( &gt; <a href="/_one/">$title</a>);

# 強調色
@color = (
"赤=f00",
"青=00f",
"緑=090"
);

}

#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------

sub start{

# CSS変更
if($alocal_mode && $age =~ /Chrome/){
$bas_style = 'http://aurasoul.mb2.jp/style/bas.css';
$style = 'http://aurasoul.mb2.jp/style/one.css';}


# スクリプト定義
if($alocal_mode){ $script = "one.cgi"; } else{ $script = "/_one/"; }

$mode = $in{'mode'};

my($flag);
if($alocal_mode || $server_domain eq "mb2.jp"){ $flag = 1; }

($submode1,$submode2,$submode3,$submode4) = split(/-/,$mode);

if($submode1 eq "view"){ require "${int_dir}one_view.pl"; }
elsif($mode eq "start"){ require "${int_dir}one_start.pl"; }
elsif($mode eq "newform"){ require "${int_dir}one_newform.pl"; }
elsif($mode eq "make_comment"){ require "${int_dir}one_makecomment.pl"; }
elsif($mode eq "make_category"){ require "${int_dir}one_makecategory.pl"; }
elsif($mode eq "change_category"){ require "${int_dir}one_changecategory.pl"; }
elsif($mode eq "del"){ require "${int_dir}one_deletecomment.pl"; }
elsif($mode eq "ecm"){ require "${int_dir}one_ecm.pl"; }
elsif($submode1 eq "vc"){ require "${int_dir}one_vc.pl"; }
elsif($submode1 eq "va"){ require "${int_dir}one_va.pl"; }
elsif($submode1 eq "edit"){ require "${int_dir}one_edit.pl"; }
elsif($mode eq ""){ require "${int_dir}one_index.pl"; }
else{ &error("ページが存在しません。[baseone]"); }
exit;

}

#-----------------------------------------------------------
# アカウントの基本ファイルを開く
#-----------------------------------------------------------
sub base_open{

my($file) = @_;

open(BASE_IN,"${int_dir}_one/_idone/${file}/${file}_base.cgi");
my $top_base = <BASE_IN>;
($key_base,$num_base,$name_base,$trip_base,$id_base,$account_base,$itrip_base,$lastnum_base,$viewtime_base,$mainnews_base,$news_base) = split(/<>/,$top_base);
close(BASE_IN);

}




1;
