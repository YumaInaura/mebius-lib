


package main;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_avrireki{

# 局所化
my($file);

#汚染チェック
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# CSS定義
$css_text .= qq(
.lim{margin-bottom:0.3em;line-height:1.25em;}
li{line-height:1.5em;}
);

# ファイルオープン
&open($file);

# ユーザー色指定
if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }

# 閲覧不許可の場合
if($pporireki eq "0" && !$myprof_flag){ &error("このメンバーは投稿履歴を公開していません。","401 Unauthorized"); }

# トリップ
if($ppenctrip){ $pri_ppenctrip = "☆$ppenctrip"; }

# タイトル決定
$sub_title = "投稿履歴 - $ppname - $ppaccount - $title";
$head_link3 = qq(&gt; $hername);


# 日記、コメントフォームなどのログ読み込み
&auth_get_avrireki($file);

# ナビ
my $link2 = "$adir${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">プロフィールへ</a>);

# HTML
my $print = <<"EOM";
$footer_link
<h1>旧投稿履歴 : $ppname - $ppaccount </h1>
$navilink
<h2>メビウスリングでの投稿履歴</h2>
$rireki_index
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}

#──────────────────────────────
# 投稿履歴
#──────────────────────────────

sub auth_get_avrireki{

# 局所化
my($ri);

# ファイル定義
my($file) = @_;


# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 投稿履歴ファイルを開く
open(RIREKI_IN,"<","${account_directory}${file}_rireki.cgi");
$rireki_line .= qq($server_domain<>$bbs_url<>$no<>$res<>$title<>$sub<>$date<>\n);
while(<RIREKI_IN>){
chomp $_;
$ri++;
my($rdomain,$rbbs_url,$rno,$rNo,$rtitle,$rsub,$rdate) = split(/<>/,$_);
if($rsub ne ""){
$rireki_index .= qq(<li><a href="http://$rdomain/$rbbs_url/$rno.html#S$rNo">$rsub</a> - <a href="http://$rdomain/$rbbs_url/">$rtitle</a></li>);
}
}
close(RIREKI_IN);

# 整形
if($rireki_index){
my($pr);
if($myprof_flag){ $pr = qq(<br><span class="red" style="font-size:90%;">＊履歴は公開されます。公開したくない場合は<a href="#EDIT">設定フォーム</a>の「投稿履歴の表\示設定」で「表\示しない」を選んでください。 By あうらゆうま</span><br>); }
$rireki_index = qq(<ul>$rireki_index</ul>$pr);

}

}


1;
