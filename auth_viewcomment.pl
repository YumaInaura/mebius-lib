
package main;

#-----------------------------------------------------------
# �`�����{��
#-----------------------------------------------------------
sub auth_view_comment{

# �錾
my($select_year,$index,$account);
local($file);

# CSS��`
$css_text .= qq(
.ctextarea{width:95%;height:35px;}
.cbottun{margin-top:0.5em;}
.clog{font-size:90%;}
.lic{margin-bottom:0.3em;line-height:1.25em;}
.deleted{font-size:90%;color:#f00;}
a.me:link{color:#f00;}
a.me:visited{color:#f40;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
td{padding:0.2em 1.0em 0.5em 0.0em;line-height:1.4em;vertical-align:top;}
input.comment{width:12em;}
);


# �����`�F�b�N
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# �A�J�E���g���J��
(%account) = &Mebius::Auth::File("Option",$file);

# �A�J�E���g��
my $viewaccount = $account{'file'};
if($account{'file'} eq "none"){ $viewaccount = "****"; }

# ��\���ݒ�̏ꍇ
if($account{'ocomment'} eq "3" && !$myadmin_flag){ &error("���̃����o�[�̓`���͔�\\���ݒ肳��Ă��܂��B","401 Unauthorized"); }

# ���[�U�[�F�w��
#if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};}); }

# �i�r
my $link2 = "${auth_url}${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
$navi .= qq(<a href="$link2">���̃����o�[�̃v���t�B�[���֖߂�</a>);

# �N�x�؂�ւ������N
my($index) .= &auth_viewcomment_get_yearlinks("",$file,%account);

# �����t�H�[��
my($searchform) = &auth_viewcomment_get_form();

# �}�C���r��Ԃ��擾

# �`�����e���擾
my($comments_line,$resform) = &view_auth_comment("Index-view",$file,$fookyear,undef,%account);

# �^�C�g����`
$year_title = qq( ( $fookyear�N ) ) if($submode2);
$sub_title = "$account{'name'}�̓`���� $year_title";
$head_link3 = qq(&gt; <a href="$auth_url$account{'file'}/">$account{'name'}</a>);
$head_link4 = qq(&gt; �`����);

if($in{'word'} ne ""){ $sub_title = "�h$in{'word'}�Ō��� - $account{'name'}�̓`���� $year_title"; }


#HTML
&header();

print qq(
<div class="body1">
$footer_link
<h1$kfontsize_h1>�`���� $year_title : $account{'name'} - $viewaccount</h1>
$navi
$index	
$searchform
<h2 id="COMMENT-INPUT"$kfontsize_h2>���e</h2>
$resform
$comments_line
<br$xclose>
$footer_link2
</div>
);

# �t�b�^
&footer();

}

#-----------------------------------------------------------
# �N�x�؂�ւ������N���擾
#-----------------------------------------------------------
sub auth_viewcomment_get_yearlinks{

my($type,$file,%account) = @_;
my($index);
our($xclose);

# ���`
if($submode2){ $index .= qq( <a href="$auth_url$file/viewcomment">�ŋ�</a> );}
else{ $index .= qq( <span class="red">�ŋ�</span> ); }

# �R�����g�C���f�b�N�X���J��
open(COMMENT_INDEX_IN,"${int_dir}_id/$file/comments/${file}_index_comment.cgi");
	while(<COMMENT_INDEX_IN>){
	chomp;
	my($year,$month) = split(/<>/);

	my $link = qq($auth_url$file/viewcomment-$year);
	if($aurl_mode){ ($link) = &aurl($link); }

	if($year eq $submode2){
		$fookyear = $year;
		$index .= qq( <span class="red">$year�N</span> );
		$select_year .= qq( <input type="radio" name="mode" value="viewcomment-$year" checked$xclose>$year�N);
	}
	else{
		$index .= qq( <a href="$link">$year�N</a> );
		$select_year .= qq( <input type="radio" name="mode" value="viewcomment-$year"$xclose>$year�N);
	}


	}
close(COMMENT_INDEX_IN);

# �C���f�b�N�X���`
if($index ne ""){ $index = qq(�@�@���� �F $index); }

return($index);

}


#-----------------------------------------------------------
# �����t�H�[��
#-----------------------------------------------------------
sub auth_viewcomment_get_form{

# �錾
my($line);
our($xclose,$kfontsize_h2);

my $checked1 = qq( checked) if(!$fookyear);

$line = qq(
<h2 id="COMMENT-SEARCH"$kfontsize_h2>����</h2>
<form action="$script">
<div>
<input type="hidden" name="account" value="$file"$xclose>
<input type="text" name="word" value="$in{'word'}" class="comment"$xclose>
<input type="submit" value="�`�����猟������"$xclose>
<input type="radio" name="mode" value="viewcomment"$checked1$xclose>�ŋ�
$select_year
<span class="guide">���M���A�A�J�E���g���A�R�����g���e���猟�����܂��B</span>
</div>
</form>

);

# ���^�[��
return($line);

}



#������������������������������������������������������������
# �`����
#������������������������������������������������������������
sub view_auth_comment{

# �Ǐ���
my($type,$file,$year,$maxview,%account) = @_;
my($i,$hit,$file,$stop,$form,$flow_flag,$comment_handler,@years,$input_years,$control_flag,$text);
our($idcheck,$kflag,$xclose,$kfontsize_h2);

# �ݒ�
if(!$maxview){ $maxview = 500; }
if($submode3 eq "all"){ $maxview = 5000; }

# CSS��`
$css_text .= qq(
h2#COMMENT,h2#COMMENT-INPUT,#COMMENT-SEARCH{background:#ff9;border-color:#fc7;}
strong.alert{font-size:90%;color:#f00;}
div.dcm{word-break:break-word;width:40em;}
table.comment{font-size:95%;width:100%;}
th.comment-date{width:20em;text-align:left;color:#f00;}
th.comment-name{width:25em;text-align:left;}
th.comment-comment{text-align:left;}
th.comment-no{text-align:left;}
tr.shadow{background:#eee;}
tr.deleted{background:#fee;color:#999;}
div.comment-next{margin-top:0.5em;text-align:right;}
div.control{text-align:right;}
div.control_submit{text-align:right;margin:0.5em 0em;}
);
if($psp_access){ $css_text .= qq(div.dcm{width:20em !important;}); }

# �����`�F�b�N
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# �t�@�C���؂�ւ�
my $open = "${int_dir}_id/$file/comments/${file}_comment.cgi";
if($year){ $open = "${int_dir}_id/$file/comments/${file}_${year}_comment.cgi"; }

# �R�����g���J��
open($comment_handler,"$open");
my $top = <$comment_handler> if(!$year); chomp $top;

	# �t�@�C����W�J
	while(<$comment_handler>){

		# �Ǐ���
		my($viewres,$control_box,$trclass,$class);

		# ���E���h�J�E���^
		$i++;

		if($hit >= $maxview){ $flow_flag = 1; last; }
		my($key,$rgtime,$account,$name,$trip,$id,$comment,$dates,$xip,$res,$deleter,$control_handle2,$res_concept2) = split(/<>/,$_);
		my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);

		# �����\���𐮌`
		my($viewdate) = sprintf("%04d/%02d/%02d %02d:%02d", $year,$month,$day,$hour,$min);

		# ���[�h����
		if($in{'word'} ne "" && ($account !~ /\Q$in{'word'}\E/ && $comment !~ /\Q$in{'word'}\E/ && $name !~ /\Q$in{'word'}\E/) ){ next; }

		my $link = qq(/_auth/$account/);
		if($aurl_mode){ ($link) = &aurl($link); }

		if($type =~ /Index-view/){ $comment =~ s/(<br>){2,}/<br>/g; }
		else{ $comment =~ s/<br>/ /g; }

		($comment) = &auth_auto_link($comment);
		if($res && $res !~ /\D/){ $viewres = qq(No.$res); }

				# ���R�����g����{�b�N�X���`
				if($idcheck && ($myadmin_flag || $submode1 eq "viewcomment")){

						# �폜�{�b�N�X ( ��ʗp )
						if($key eq "1" && ($file eq $pmfile || $account eq $pmfile) && !$myadmin_flag){
							$control_box .= qq( <input type="checkbox" name="rgtime$rgtime" value="delete"$xclose> �R�����g���폜);
						}

						# ���폜�{�b�N�X ( �Ǘ��p )
						if($key eq "1" && $myadmin_flag){
							$control_box .= qq( <input type="radio" name="rgtime$rgtime" value="penalty" id="penalty$res"$xclose><label for="penalty$res" class="red">���폜</label>);
						}

						# �폜�{�b�N�X ( �Ǘ��p )
						if($key eq "1" && $myadmin_flag){
							$control_box .= qq( <input type="radio" name="rgtime$rgtime" value="delete" id="delete$res"$xclose><label for="delete$res">�폜</label>);
						}

						# �����{�b�N�X
						if($key ne "1" && $myadmin_flag){
							$control_box .= qq( <input type="radio" name="rgtime$rgtime" value="revive" id="revive$res"$xclose><label for="revive$res" class="blue">����</label>);
						}

						# ����{�b�N�X�̐��`�i�Ǘ��p�j
						if($control_box && $myadmin_flag){
							$control_box = qq( <input type="radio" name="rgtime$rgtime" value="" id="none$res"$main::checked$xclose><label for="none$res">���I��</label>$control_box);
						}

						# ����{�b�N�X�̐��`�i���ʁj
						if($control_box){
							$control_flag = 1;
							$control_box = qq(<br$main::xclose><div class="control">$control_box</div>);
						}

				}

			# �폜�ς݂̏ꍇ
			if($key ne "1"){
				my($deleted_text);
				if($key eq "2"){ $deleted_text = qq(�y�A�J�E���g��폜�z); }
				elsif($key eq "3"){ $deleted_text = qq(�y���e��폜�z); }
				elsif($key eq "4"){ $deleted_text = qq(�y�Ǘ��ҍ폜�z $deleter); }

				if($myadmin_flag){ $comment = qq(<span class="deleted">$comment $deleted_text $res_concept2</span>); }
				else{ $comment = qq(<span class="deleted">$deleted_text</span>); }

			}

				# �s�̕\���X�^�C�����`
				if($account eq $file){ $class = qq( class="me"); }
				if($key ne "1" && $myadmin_flag){ $trclass = qq( class="deleted"); }
				elsif($i % 2 == 0){ $trclass = qq( class="shadow"); }

				# �\���s���`�i�g�сj
				if($kflag || $psp_access){
					$comments .= qq(<li id="C$res"$trclass><a href="$link"$class>$name - $account</a>);
					$comments .= qq( ( <a href="$link#COMMENT">�ԐM</a> ) $comment $del);
					$comments .= qq( $viewdate - $viewres$control_box</li>);
				}

				# �\���s���`�i�o�b�j
				else{
					$comments .= qq(<tr id="C$res"$trclass><td><a href="$link"$class>$name - $account</a>);
					$comments .= qq( ( <a href="$link#COMMENT">�ԐM</a> )</td><td><div class="dcm">$comment $del</div></td>);
					$comments .= qq(<td>$viewdate - $viewres$control_box</td></tr>);
				}

		# �q�b�g�J�E���^
		$hit++;

	}

close($comment_handler);

# ���o����`
my $h2 = qq(<h2 id="COMMENT"$kfontsize_h2>�`����</h2>);
if($type =~ /PROF/ && $flow_flag){ $h2 = qq(<h2 id="COMMENT"$kfontsize_h2><a href="viewcomment#COMMENT">�`����</a></h2>); }

	# �R�����g�������`
	if($comments){
		if($kflag){
			$comments = qq($h2\n<ul>$comments</ul>);
		}
		else{
$comments = qq(
$h2
<table summary="�`���ꗗ" class="comment">
<tr><th class="comment-name">�M��</th><th class="comment-comment">�`��</th><th class="comment-date">����</th></tr>\n
$comments
</table>
);
		}
	}
	else{ $comments = $h2; }

	# ����
	if($year && $type !~ /PROF/ && $flow_flag){ $comments = qq($comments<a href="./viewcomment-$year-all">����</a>); }

	# �R�����g�ۂ̔���
	if($account{'let_flag'}){ $form .= qq(��$account{'let_flag'}); $stop = 1; }
	elsif($account{'key'} eq "2"){ $form .= qq(���A�J�E���g�����b�N���̂��ߏ������߂܂���<br$xclose>); $stop = 1; }
	elsif($account{'friend_status_to'} eq "deny"){ $form .= qq(���֎~�ݒ蒆�̂��߃R�����g�ł��܂���<br$xclose>); $stop = 1; }
	elsif($account{'ocomment'} eq "0"){ $form .= qq(���A�J�E���g�� ( $file ) �������R�����g�ł��܂�<br$xclose>); if(!$account{'myprof_flag'}){ $stop = 1; } }
	elsif($account{'ocomment'} eq "2"){ $form .= qq(��$friend_tag�������R�����g�ł��܂�<br$xclose>); if($account{'friend_status_to'} ne "friend" && !$account{'myprof_flag'}){ $stop = 1; }  }

	# ���O�C���֌W
	if(!$idcheck){ $form = qq(���R�����g����ɂ�<a href="$auth_url?backurl=$selfurl_enc">���O�C���i�܂��͐V�K�o�^�j</a>���Ă��������B<br$xclose>); $stop = 1; }
	elsif($birdflag){ $form = qq(���R�����g����ɂ�<a href="$auth_url$pmfile/#EDIT">���Ȃ��̕M��</a>��ݒ肵�Ă��������B<br$xclose>); $stop = 1; }

# �g�s�l�k�ŏI�o�͒�`
$form .= qq(������J - ���Ȃ��ȊO�ɂ͌����܂��� ) if($account{'ocomment'} eq "3");


	# �҂����ԕ\��
	if($main::time < $main::myaccount{'next_comment_time'}){
		my($next_splittime) = &Mebius::SplitTime(undef,$main::myaccount{'next_comment_time'}-$main::time);
		$form .= qq( �����݃`���[�W���Ԓ��ł��B����$next_splittime�ŏ������߂܂��B);
	}

	# �Ǘ��҂̏ꍇ
	if($myadmin_flag){ $stop = ""; }

	# �R�����g�t�H�[����ʏ�\��
	if($main::stop_mode =~ /SNS/){
		$form .= qq(<div><br$main::xclose><span class="alert">���݁ASNS�S�̂œ��e��~���ł��B</span></div>);
	}
	elsif(!$stop){
$form .= <<"EOM";
<form action="$action" method="post" class="pform"$sikibetu>
<div>
<textarea name="comment" class="ctextarea" cols="25" rows="5"></textarea>
<br$xclose><input type="submit" value="���̓��e�œ`������"$xclose>
<input type="hidden" name="mode" value="comment"$xclose>
<input type="hidden" name="account" value="$file"$xclose>
<strong class="alert">�������ނ� �ڑ��f�[�^ ( $addr ) ���T�[�o�[�����ɋL�^����A <a href="${adir}aview-allcomment.html">�V���`��</a> ���X�V����܂��B �@</strong>
<span class="guide">�i�S�p$max_msg_comment�����܂Łj�B</span>
</div>
</form>
EOM
	}

	# �R�����g����{�^��
	if($control_flag){

		# �Ǐ���
		my($method);
		our($backurl_input);

		# ���\�b�h��`
		#if($alocal_mode){ $method = "get"; }
		#else{ $method = "post"; }
		$method = "post";

		$comments = qq(
		<form action="$auth_url" method="$method"$sikibetu>
		<div>
		$comments
		<input type="hidden" name="mode" value="comdel"$xclose>
		<input type="hidden" name="account" value="$file"$xclose>
		<input type="hidden" name="year" value="$submode2"$xclose>
		<input type="hidden" name="thismode" value="$mode"$xclose>
		$input_years 
		$backurl_input
		<div class="control_submit">
		<input type="submit" value="�R�����g��������s����"$xclose>
		</div>
		</div>
		</form>
		);
	}

	# ���`
	if($type =~ /PROF/){
$comments = qq(
$comments
<div class="comment-next">
<a href="viewcomment#COMMENT">�������̃��b�Z�[�W</a>
</div>
);
	}

return($comments,$form);

}

1;
