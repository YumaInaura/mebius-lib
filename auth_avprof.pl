
#-----------------------------------------------------------
# プロフィール全文を見る
#-----------------------------------------------------------
sub auth_avprof{

# 局所化
my($i,$kadsense,$max,$print);

# 設定
$max = 40;

# モードエラー
if($submode3){ &error("モードが存在しません。$mode "); }

# 携帯版を判定
if($submode1 eq "kview"){
&kget_items("");
$kcanonical = "${auth_url}kview-prof";
}

# ファイルオープン
&open("$in{'account'}");


# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($in{'account'});
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# プロフィール専用ファイルから取得
#if($ppprof eq ""){
#open(PROF_IN,"<","${account_directory}${ppfile}_prof.cgi");
#my $top = <PROF_IN>;
#($ppprof) = split(/<>/,$top);
#close(PROF_IN);
#}

# プロフィール定義
foreach(split(/<br>/,$ppprof)){
$i++;
if($i == $max){ $pri_prof .= qq(<a name="AVIEW" id="AVIEW"></a>); }
$_ = &auth_auto_link($_);
$pri_prof .= qq($_<br$xclose>\n);
}

# 携帯版の広告を定義
if($i >= 5 && $kflag){
($kadsense) = &kadsense;
$kadsense = qq($kadsense<hr$xclose>);
}

# 整形
if(!$i){ $i = 0; }

# タイトル
$sub_title = "$ppname - $ppaccount のプロフィール";

	# 携帯版の表示
	if($kflag){
		$print = qq(
		$ppname - $ppfile のプロフィール($i行)
		<hr$xclose>
		$kadsense
		$pri_prof
		);
	}

	# ＰＣ版の表示
	else{
		$print = qq(
		<h1>$ppname - $ppfile のプロフィール($i行)</h1>
		$pri_prof
		);
	}

Mebius::Template::gzip_and_print_all({},$print);


exit;

}



1;
