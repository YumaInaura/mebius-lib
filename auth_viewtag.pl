
package main;

#-----------------------------------------------------------
# �A�J�E���g���̃^�O�{��
#-----------------------------------------------------------
sub auth_viewtag{

# �Ǐ���
my($type,$file,$maxtag,$max_comment) = @_;
my($tagline,$i);

# �t�@�C���I�[�v��
&open($file);

# �ő啶����
my $maxlength = 40;

# ���[�U�[�F�w��
if($ppcolor1){
$css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;});
}

# CSS��`
$css_text .= qq(
.tag_input{width:12em;}
.comment_input{width:15em;}
div.alert{font-size:90%;background-color:#fff;padding:1em;margin-top:1em;border:solid 1px #f00;line-height:1.5em;}
);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �}�C�^�O�t�@�C�����J��
my $openfile1 = "${account_directory}${file}_tag.cgi";
open(MYTAG_IN,"$openfile1");
	while(<MYTAG_IN>){
		my($key,$tag) = split(/<>/,$_);
			if(Mebius::Fillter::heavy_fillter(utf8_return($tag))){ next; }

		if($key ne "1" && !$myadmin_flag){ next; }
		$i++;
		if($key eq "1"){ $iok++; }
		my $enctag2 = $tag;
		$enctag2 =~ s/([^\w])/'%' . unpack("H2" , $1)/eg;
		$enctag2 =~ tr/ /+/;

		my $link = "${adir}tag-word-${enctag2}.html";
		if($aurl_mode){ ($link) = "$script?mode=tag-word-${enctag2}"; }
		$tagline .= qq(\n<li><a href="$link">$tag</a>);
		if($key eq "2"){ $tagline .= qq(�@<span class="red">(�폜��)</span>); }
		elsif($myprof_flag || $myadmin_flag){
		if($aurl_mode){ $tagline .= qq( - <a href="$script?mode=tag-delete-${enctag2}&amp;account=$file">�폜</a>)}
		else{ $tagline .= qq( - <a href="${adir}?mode=tag-delete-${enctag2}&amp;account=$file">�폜</a>); }
		if($myadmin_flag){
		if($aurl_mode){ $tagline .= qq( - (<a href="$script?mode=tag-delete-${enctag2}&amp;account=$file&amp;penalty=1">�y�i���e�B�폜</a>))}
		else{ $tagline .= qq( - (<a href="${adir}?mode=tag-delete-${enctag2}&amp;account=$file&amp;penalty=1">�y�i���e�B�폜</a>)); }
		}
		}
	}
close(MYTAG_IN);

# �҂����Ԏ擾
&get_waittime("",$file);

# �o�^�[���̏ꍇ
if(!$iok){ $iok = 0; }

# ���X�g���`
if($tagline ne ""){ $tagline = qq(<h2>�o�^���̃^�O ($iok)</h2><ul>$tagline</ul>); }

# �^�O�����t�H�[�����擾
&get_schform;

# �^�C�g����`
$sub_title = "$ppname�̃^�O - $title";

# HTML
my($form);

# ���[�J�������N
if($alocal_mode){
$alocal_links = qq(
<br><a href="$script?mode=tag-new">�V���^�O</a>
<a href="$script?mode=tag-sch">�^�O����</a>
);
}


	# �X�g�b�v���[�h
	if($myprof_flag && $main::stop_mode =~ /SNS/){
		$form = qq(<h2>�^�O�̓o�^</h2>\n<div><span class="alert">���݁ASNS�S�̂ōX�V��~���ł��B</span></div>\n);
	}

# �t�H�[������
elsif($myprof_flag){
$form = qq(
<h2>�^�O�̓o�^</h2>
<form action="$action" method="post" class="myform"$sikibetu>
<div>
�^�O�F <input type="text" name="tag" value="" maxlength="$maxlength" class="tag_input">
�@�R�����g�F <input type="text" name="comment" value="" maxlength="$max_comment" class="comment_input">
�@<input type="submit" value="�^�O��ǉ�����">

<input type="hidden" name="mode" value="tag-maketag">
<input type="hidden" name="account" value="$in{'account'}">

<br>$alocal_links
<div class="alert">
$next_hour
���u��v�u���i�v�u�D���Ȃ��́v�Ȃ�<strong class="red">���Ȃ��Ɋւ���L�[���[�h</strong>��o�^���Ă��������i��F �Ǐ��A�y�V�Ɓj�B�����^�O�o�^���Ă��郁���o�[�ƃ����N���邱�Ƃ��o���܂��B<br>
���^�O���g���Ắu�g���C�A���v�u�A���P�[�g�v�u�f�����p�v�u�`���b�g�v�͂��������������i�Q�O�O�X�N�V�����j�B�e�[�}������Ęb������ꍇ��<a href="http://mb2.jp/">�f����</a>�������p���������B<br>
<span class="red">���l���A���I�ȃL�[���[�h�A�o�b�V���O�ړI�A�ᔻ�E���ړI�A�l�|�A�^�c�W�Q�A���Ӗ��ȒP��A���f�ȓ��e�Ȃǂ̓o�^�͋֎~�ł�(<a href="${guide_url}%A5%BF%A5%B0">���^�O�ɂ���</a>)�B
�Ǘ��҂��^�O���폜����ƁA���΂炭�^�O���ǉ��ł��Ȃ��Ȃ�܂��B�܂��A�^�O�폜�ɂ��Ă̊Ǘ��Ґ����͂���܂���B</span><br>
���^�O�͉����ɔ��΂�����A�������U���E�ᔻ�E���邽�߂��̂ł͂���܂���B�����������Ȃ��ɂ�<a href="http://aurasoul.mb2.jp/">�f����</a>�𗘗p���Ă��������B�^�c�v�]�Ȃǂ�<a href="http://aurasoul.mb2.jp/_qst/2245.html">����^�c��</a>�܂ł��肢���܂��B<br>
���ő�$maxtag���܂œo�^�ł��܂� (����$iok��) �B�^�O�͑S�p20�����A�R�����g�͑S�p$max_comment�����܂œo�^�ł��܂��B<br>
���^�O����̂��߁A�ꕔ�̋L���͎����ϊ�����܂��B<br>
</div>
</div>
</form>

);
}

my $print = qq(
$footer_link
<h1>$ppname - $ppfile �̃^�O</h1>
<a href="$adir${file}/">�v���t�B�[����</a>
 - <a href="${adir}tag-new.html">�V���^�O���`�F�b�N����</a>
$schform
<br>

$form
$tagline
</div>

);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ���̑҂�����
#-----------------------------------------------------------
sub get_waittime{

my($type,$file) = @_;

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

open(PENALTY_IN,"<","${account_directory}${file}_time_tag.cgi");
my $top = <PENALTY_IN>;
my($nexttime) = split(/<>/,$top);
if($nexttime - $time <= 0){ return; }
$next_hour = int(($nexttime - $time)/3600)-1;
close(PENALTY_IN);
if($next_hour){ $next_hour = qq(���҂�����$next_hour���Ԃł��B<br>); }
}

1;
