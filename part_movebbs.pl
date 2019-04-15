
use strict;
package main;

#-------------------------------------------------
# 掲示板全体を移転（リダイレクト）
#-------------------------------------------------
sub movebbs_redirect{

# 宣言
my($type,$bbs_redirect) = @_;
my($redirect_url,$type2,$No,$r);

($bbs_redirect,$type2) = split(/>/,$bbs_redirect);

	# 単一のＵＲＬにリダイレクト
	if($type2 eq "simple_redirect"){
		$redirect_url = $bbs_redirect;
	}

	# 新しい掲示板にリダイレクト
	else{

		my $request_uri = $ENV{'REQUEST_URI'};
		# 整形
		$request_uri =~ s!^/!!g;
		$redirect_url = "$bbs_redirect$request_uri";
	}

# 自サーバーかどうかチェック
my($justy_url_flag) = Mebius::Init::AllDomains({ TypeJustyCheck => 1 , URL => $redirect_url } );

	# リダイレクト実行
	Mebius::Redirect("301",$redirect_url);


exit;

}

1;

