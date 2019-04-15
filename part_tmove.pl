
package main;

#-----------------------------------------------------------
# となりの記事へ移動
#-----------------------------------------------------------

sub bbs_tmove{

# 局所化
my($i,$file,$no,$flag);

# ファイル定義
$file = $in{'no'};
$file =~ s/\D//;
if($file eq ""){ &error("記事を指定してください。"); }

# 年齢
my($Age);
if(!$cage){ $Age = 0; }
else{ $Age = $thisyear - $cage; }

	# 繰り返し処理
	for(1..15){
		$i++;

		if($in{'next'}){ $file++; } else { $file--; }
		if($file < 0){ last; }

		my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$realmoto,$file);


				if($thread->{'sexvio'} >= 1 && $Age < 15){ next; }
				if($thread->{'sexvio'} >= 2 && $Age < 18){ next; }
				if($thread->{'keylevel'} >= 0.5){ $jump_no = $file; $flag = 1; last; }

	}


# リダイレクト
if(!$flag){ Mebius::Redirect("","http://$server_domain/_$realmoto/",301); }
else{ Mebius::Redirect("","http://$server_domain/_$realmoto/$jump_no.html",301); }

exit;

}

1;
