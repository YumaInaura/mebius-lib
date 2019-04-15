
use strict;
use Mebius::Getstatus;
package Mebius;

#-----------------------------------------------------------
# Not Found エラーページ - strict
#-----------------------------------------------------------
sub ServerAlive{

my($server_access_flag,$success_flag);

	# 自サーバーからのアクセスのみ許容
	foreach(@main::server_addrs){
			if($main::addr eq $_){ $server_access_flag = 1; }
	}
	if(!$server_access_flag && !$main::alocal_mode){ &main::error("この機\能\は使えません。"); }


	# ドメインを展開
	foreach(@main::domains){

		# 局所化
		my($success_flag,$get_status_url);

		# 自分自身は調べない
		if($_ eq $main::server_domain){ next; }

		# 取得するURLを定義
		$get_status_url = "http://$_/";

		# ステータスをゲット
		for(1..5){

			# ステータスをゲット
			my($status) = &Mebius::Getstatus(undef,$get_status_url);

			# 判定
			if($status eq "200"){ $success_flag = 1; last; }
			else{ sleep(1); }

		}

		# 200 OK が一度も返らなかった場合、メールを送信
		if(!$success_flag){ &Mebius::Email(undef,$main::admin_mail_mobile,"$_ サーバー接続不可","$_ のサーバーに上手く繋がらないようです。"); }


	}

# HTML
print "Content-type:text/html\n\n";
print qq(Server alive check was done);

exit;

}




1;
