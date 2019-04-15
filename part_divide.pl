
#-----------------------------------------------------------
# アクセス振り分け
#-----------------------------------------------------------
sub do_divide{

# 宣言
my($url,$type) = @_;
our($int_dir,$agent,$requri,$server_domain);

	# リターン
	if($url eq ""){ return; }

	# 記録
	if($type eq "mobile"){
			if($bot_access){ Mebius::AccessLog(undef,"BOT-DIVIDE-TO-MOBILE"); }
			else{ Mebius::AccessLog(undef,"DIVIDE-TO-MOBILE"); }
	}
	if($type eq "desktop"){
			if($bot_access){ Mebius::AccessLog(undef,"BOT-DIVIDE-TO-DESKTOP"); }
			else{ Mebius::AccessLog(undef,"DIVIDE-TO-DESKTOP"); }
	}

# URLを整形 ( 暫時 )
$url =~ s/moto=([a-z0-9]+)&//g;

# リダイレクトして処理終了
Mebius::Redirect("",$url);

exit;

}

1;
