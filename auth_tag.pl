
package main;

#-----------------------------------------------------------
# �r�m�r�^�O
#-----------------------------------------------------------
sub auth_tag{

# �錾
my($file,$maxtag,$max_comment);


# �t�@�C����`
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# �^�O�ő�o�^��
$maxtag = 300;

# �R�����g�ő啶����
$max_comment = 100;

	# ���[�h�U�蕪��
	if($submode2 eq "maketag"){ require "${int_dir}auth_maketag.pl"; &auth_maketag("",$file,$maxtag,$max_comment); }
	elsif($submode2 eq "delete"){ require "${int_dir}auth_deletetag.pl"; &auth_deletetag("",$file,$maxtag,$max_comment); }
	elsif($submode2 eq "close"){ require "${int_dir}auth_closetag.pl"; &auth_closetag("",$file,$maxtag,$max_comment); }
	elsif($submode2 eq "new"){ require "${int_dir}auth_newtag.pl"; &auth_newtag("",$file,$maxtag,$max_comment); }
	elsif($submode2 eq "view"){ require "${int_dir}auth_viewtag.pl"; &auth_viewtag("",$file,$maxtag,$max_comment); }
	elsif($submode2 eq "word"){ require "${int_dir}auth_wordtag.pl"; &auth_wordtag("",$file,$maxtag,$max_comment); }
	elsif($submode2 eq "sch"){ require "${int_dir}auth_schtag.pl"; &auth_schtag("",$file,$maxtag,$max_comment); }
	#elsif($submode2 eq "fook"){ require "${int_dir}auth_fooktag.p;"; &auth_fooktag("",$file,$maxtag,$max_comment); }
	else{ &error("�y�[�W�����݂��܂���B[atg]"); }

exit;

}

#-----------------------------------------------------------
# ���ʌ����t�H�[��
#-----------------------------------------------------------
sub get_schform{

# ���ʌ����t�H�[��
$css_text .= qq(
.schform{margin:0em;display:inline;}
.schdiv{margin:0em;display:inline;}
);

	# �t�H�[�J�X�𓖂Ă�
	if(!exists $main::in{'word'}){
		$body_javascript = qq( onload="document.tag_search.word.focus()");
	}

# �����t�H�[��
$schform = qq(
<form action="$action" class="schform" name="tag_search"$sikibetu><div class="schdiv">
<input type="hidden" name="mode" value="tag-sch">
<input type="text" name="word" value="$in{'word'}">
<input type="submit" value="�^�O����">
</div></form>
);

}



1;
