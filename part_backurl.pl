
#-----------------------------------------------------------
# ���t�@������A�߂���`
#-----------------------------------------------------------
sub get_backurl{

# �Ǐ���
my($type,$url) = @_;
my($xclose2) = our($xclose);
my($real_referer);
my @deny_words = ('pagead2','pub-');
our($referer,%in,$kflag,$postflag,$backurl_jak_flag);
our($backurl,$backurl_link,$backurl_query,$backurl_query_enc,$backurl_input) = undef;

	# �I�t�̏ꍇ
	if($in{'backurl'} eq "off"){ return; }

# URL�̃f�X�P�[�v
($url) = Mebius::Descape("",$url);

	# �h���C���̐��K�`�F�b�N
	foreach(@main::all_domains){

			# ���p���l����߂��𔻒�
			if($url =~ /^http(s)?:\/\/($_)\//){ $backurl = $url; }

			# ���t�@������߂��𔻒�
			if($url eq "" && $referer && !$postflag && !$bot_access && $type !~ /NOREFERER/){
				my($real_referer) = Mebius::Descape("",$referer);
					foreach(@domains){
						if($real_referer =~ /^http(s)?:\/\/($_)\//){ $backurl = $real_referer; }
					}
			}

	}


	# �֎~���镶����
	foreach(@deny_words){
			if($backurl =~ /$_/){ $backurl = ""; }
	}

	# �e�l�̐��`
	if($backurl){

		# �߂�悪�Ǘ����[�h�̏ꍇ
		if($backurl =~ /$jak_url/){ $backurl_jak_flag = 1; }
		if($backurl =~ m|/admin/| && $alocal_mode){ $backurl_jak_flag = 1; }

		our($backurl_href) = Mebius::escape("",$backurl);
		$backurl_link = qq(<a href="$backurl_href">���̃y�[�W�ɖ߂�</a>);
		our ($backurl_enc) = Mebius::Encode("",$backurl);
		$backurl_query = "&backurl=$backurl_enc";
		$backurl_query_enc = "&amp;backurl=$backurl_enc";
				if($kflag || $main::in{'k'} || $main::in{'mode'} =~ /k(view|index)/){ $xclose2 = qq( /); } # �b��[�u�H
		$backurl_input = qq(<input type="hidden" name="backurl" value="$backurl_href"$xclose2>); # &amp; ������̂͂���ŗǂ��̂��iHTML�̎��ԎQ�Ɓj
	}


}


1;
