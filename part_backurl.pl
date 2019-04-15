
#-----------------------------------------------------------
# リファラ判定、戻り先定義
#-----------------------------------------------------------
sub get_backurl{

# 局所化
my($type,$url) = @_;
my($xclose2) = our($xclose);
my($real_referer);
my @deny_words = ('pagead2','pub-');
our($referer,%in,$kflag,$postflag,$backurl_jak_flag);
our($backurl,$backurl_link,$backurl_query,$backurl_query_enc,$backurl_input) = undef;

	# オフの場合
	if($in{'backurl'} eq "off"){ return; }

# URLのデスケープ
($url) = Mebius::Descape("",$url);

	# ドメインの正規チェック
	foreach(@main::all_domains){

			# 引継ぎ値から戻り先を判定
			if($url =~ /^http(s)?:\/\/($_)\//){ $backurl = $url; }

			# リファラから戻り先を判定
			if($url eq "" && $referer && !$postflag && !$bot_access && $type !~ /NOREFERER/){
				my($real_referer) = Mebius::Descape("",$referer);
					foreach(@domains){
						if($real_referer =~ /^http(s)?:\/\/($_)\//){ $backurl = $real_referer; }
					}
			}

	}


	# 禁止する文字列
	foreach(@deny_words){
			if($backurl =~ /$_/){ $backurl = ""; }
	}

	# 各値の整形
	if($backurl){

		# 戻り先が管理モードの場合
		if($backurl =~ /$jak_url/){ $backurl_jak_flag = 1; }
		if($backurl =~ m|/admin/| && $alocal_mode){ $backurl_jak_flag = 1; }

		our($backurl_href) = Mebius::escape("",$backurl);
		$backurl_link = qq(<a href="$backurl_href">元のページに戻る</a>);
		our ($backurl_enc) = Mebius::Encode("",$backurl);
		$backurl_query = "&backurl=$backurl_enc";
		$backurl_query_enc = "&amp;backurl=$backurl_enc";
				if($kflag || $main::in{'k'} || $main::in{'mode'} =~ /k(view|index)/){ $xclose2 = qq( /); } # 暫定措置？
		$backurl_input = qq(<input type="hidden" name="backurl" value="$backurl_href"$xclose2>); # &amp; が入るのはこれで良いのだ（HTMLの実態参照）
	}


}


1;
