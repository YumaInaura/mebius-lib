
package main;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_avlogin{

# 局所化
my($file,$acbk_line,$first_line,$rlogin_line,$domain_links);
my($my_account) = Mebius::my_account();
our($server_domain);


#汚染チェック
$file = $submode3;
$file =~ s/[^0-9a-z]//g;

# CSS定義
$css_text .= qq(
table.login_history{width:100%;}
);

# ファイルを開く
&open($file);


	# 管理者でも自分自身でもない場合
	if(!$my_account->{'admin_flag'} && $my_account->{'id'} ne $file){ &error("自分の情報以外は閲覧できません。","401"); }

# 旧ログイン履歴
($rlogin_line,$first_line) = &auth_get_loginhistory("",$file);

# 筆名
my($line_names) = &auth_get_namehistory("",$file);

# 新ログイン履歴
my($index_line) = shift_jis(Mebius::Login->login_history("Index",$file,$my_account->{'id'}));

# タイトル決定
$sub_title = "ログイン履歴 - $title";
$head_link3 = qq(&gt; ログイン履歴 - $title);

# ナビ
my $link2 = "${auth_url}${ppfile}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">このメンバーのアカウントへ戻る</a>);

# HTML
my $print = <<"EOM";
$footer_link
<h1>各種履歴： $ppname - $ppaccount</h1>
$navilink
$domain_links
<h2>アクセス履歴</h2>
$index_line
$first_line
$line_names
$rlogin_line
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}

#-----------------------------------------------------------
# 各種データ取得
#-----------------------------------------------------------

sub auth_get_loginhistory{

# 局所化
my($type,$file) = @_;
my($top);

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 初期データを開く
open(FIRST_IN,"<","${account_directory}${ppaccount}_first.cgi");
my $top = <FIRST_IN>;
my($time2,$date2,$xip2,$host2,$age2,$cnumber2,$put_pass2) = split(/<>/,$top);
close(FIRST_IN);

$first_line .= qq(登録日： $date2 );

	# 管理者だけに表示
	if($myadmin_flag >= 1){
		$first_line .= qq(管理番号： ) . Mebius::Admin::user_control_link_cookie($cnumber2);
		$first_line .= qq( AGENT: ) . Mebius::Admin::user_control_link_user_agent($age2);
	}

	# マスターだけに表示
	if($myadmin_flag >= 5){
		$first_line .= qq( - HOST:  ) . Mebius::Admin::user_control_link_host($host2) . qq( - XIP: $xip2 - PASS: $put_pass2);
	}

	# 自分だけに表示
	if($file eq $pmfile && $myadmin_flag < 5){
		$first_line .= qq( ユーザーエージェント： $age2 );
	}

$first_line = qq(<h2>初期データ</h2><ul>$first_line</ul>);


# 更新時データを開く
open(ACBK_IN,"<","${account_directory}${ppaccount}_acbk.cgi");
my $top2 = <ACBK_IN>;
my($none,$none,$acpass) = split(/<>/,$top2);
close(ACBK_IN);
if($myadmin_flag >= 5 && $acpass){ $acbk_line = qq(<h2>更新前データ</h2>PASS: $acpass); }

# 管理者でない場合
if(!$myadmin_flag){ return("",$first_line); }

# ”旧”ログイン履歴を開く
open(RLOGIN_IN,"<","${account_directory}${ppaccount}_rlogin.cgi");
	while(<RLOGIN_IN>){
		chomp;
		my($lasttime,$xip2,$host2,$number,$id) = split(/<>/);

		my($login_date) = Mebius::Getdate("",$lasttime);
		$xip2 =~ tr/+/ /;
		$xip2 =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("H2", $1)/eg;
		$rlogin_line .= qq(<li>);
		$rlogin_line .= qq(ログイン時間： $login_date ( $lasttime ) - 管理番号： );
		$rlogin_line .= Mebius::Admin::user_control_link_cookie($number);
		$rlogin_line .= qq( - ID: $id );
			if($myadmin_flag >= 5){
				$rlogin_line .= qq(- XIP: $xip2 - HOST: );
				$rlogin_line .= Mebius::Admin::user_control_link_host($host2);
			}
	}
close(RLOGIN_IN);
$rlogin_line = qq(<h2>ログイン履歴(旧)</h2><ul>$rlogin_line</ul>);

return($rlogin_line,$first_line);


}

#-----------------------------------------------------------
# 筆名履歴を取得
#-----------------------------------------------------------
sub auth_get_namehistory{

# 局所化
my($type,$file) = @_;
my($i,$line);

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイルを開く
open(NAME_IN,"<","${account_directory}${file}_name.cgi");
while(<NAME_IN>){
chomp;
$i++;
#if($i >= 2){ $line .= qq( - ); }
my($name) = split(/<>/);
$line .= qq(<li>$name\n);
}
close(NAME_IN);

$line = qq(<h2>筆名履歴</h2><ul>$line</ul>);

return($line);

}



1;
