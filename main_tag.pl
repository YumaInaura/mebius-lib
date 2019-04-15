
use Mebius::BBS;
use Mebius::History;
use Mebius::Tag;

#-----------------------------------------------------------
# �^�O�̋��ʐݒ�
#-----------------------------------------------------------
sub getinit_tag_base{
my($maxtag,$maxlength_tag) = (10,10);
$maxtag = 10;
$maxlength_tag = 10;
return($maxtag,$maxlength_tag);
}

#-----------------------------------------------------------
# ���[�h�U�蕪��
#-----------------------------------------------------------
sub do_tag{

# �^�C�g���Ȃǒ�`
$sub_title = "�^�O";
$head_link2 = qq(&gt; <a href="http://$server_domain/">$server_domain</a>);
$head_link3 = qq( &gt; <a href="/_main/newtag-$submode2-1.html">�^�O</a>);

# ���[�h�U�蕪��
if($submode2 eq "make" || $submode2 eq "delete" || $submode2 eq "edit"){ &edittag("$submode2"); }
elsif($submode3 eq "v"){ &view_tag($submode4); }
elsif($submode3 eq "all"){ &view_alltag(); }
else{ &error("���̃��[�h�͑��݂��܂���B"); }
}

#-----------------------------------------------------------
# �^�O�P�̃y�[�W��\��
#-----------------------------------------------------------
sub view_tag{

# �Ǐ���
my($tagname) = @_;
my($enctagname,$line,$type,$adform,$keytext,$ads);

# �^�O�̋��ʐݒ����荞��
my($maxtag,$maxlength_tag) = &getinit_tag_base();

# CSS��`
$css_text .= qq(
table,th,tr,td{border-style:none;}
table{margin: 1em 0em;width:70%;}
td{padding:0.3em 0em;}
td.sub{width:20em;}
h2{background:#bdd;}
h2{padding:0.4em 0.7em;font-size:110%;}
);

# �^�C�v����
if($submode2 eq "p"){ }
elsif($submode2 eq "k"){ &kget_items; $type .= " MOBILE"; }
else{ &error("���̕\\�����[�h�͑��݂��܂���B"); }

# �G���R�[�h
($enctagname) = Mebius::Encode("",$tagname);

# �^�O�P�̃t�@�C�����擾
my($flag,$line,$tagnum,$tagkey) = &open_tag("VIEW$type",$tagname,$enctagname);

# �^�O�t�@�C�������݂��Ȃ��ꍇ
if(!$flag){ &error("���̃^�O�͑��݂��܂���B"); }

# ���A���b�N��
if($tagkey eq "close"){
if($admin_mode){ $keytext = qq(<strong class="red">�����̃^�O�͕����ł��B</strong>); }
else{ &error("���̃^�O�͕����ł��B","410"); }
}
elsif($tagkey eq "lock"){ $keytext = qq(<strong class="red">�����̃^�O�̓��b�N����Ă��܂��B</strong>); }

# �Ǘ��҃t�H�[��
if($admin_mode){ 
$adform .= qq(<a href="$script?mode=tag-edit&amp;type=close&amp;tagname=$enctagname&amp;place=tag">��</a> );
$adform .= qq(<a href="$script?mode=tag-edit&amp;type=lock&amp;tagname=$enctagname&amp;place=tag">���b�N</a> );
}

# �L�����`
if($tagnum >= 1){
$ads = qq(
<h2>�X�|���T�[�h�����N</h2>
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* �L���f�[�^ */
google_ad_slot = "9966248153";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);
if($alocal_mode || $admin_mode || $kflag){ $ads = ""; }
}

# �^�C�g����`
$sub_title = "$tagname | �^�O";
$head_link4 = qq( &gt; $tagname );

# �����t�H�[�����Q�b�g
my($tagsearch_form) = &get_tagsearch_form("FOCUS");


# HTML
my $print = qq(
<h1>$tagname - �^�O</h1>
<a href="/">�s�n�o�y�[�W�ɖ߂�</a>�@
<a href="/_main/newtag-$submode2-1.html">�V���^�O</a>�@
$tagsearch_form
$adform
$keytext
<h2>�h$tagname�h�Ɋ֌W����L�� ( $tagnum )</h2>
$line
$ads
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# �^�O�̍쐬�A�ҏW�A�폜
#-----------------------------------------------------------
sub edittag{

# �Ǐ���
my($type) = @_;
my($tagname,@line1,@line2,$title,$plustype,$flag_newtag,@line_newtag,$init_bbs);

# �^�O�̋��ʐݒ����荞��
my($maxtag,$maxlength_tag) = &getinit_tag_base();

# �A�N�Z�X����
&axscheck("ACCOUNT");

# ID�ƊǗ��ԍ����Z�b�g
our($encid) = &id();

# �����`�F�b�N
my($tagname) = split(/\0/,$in{'tagname'});

# �����`�F�b�N
if($submode2 eq "delete" && !$admin_mode){ &error("���s����������܂���B"); }
if($submode2 eq "edit" && !$admin_mode){ &error("���s����������܂���B"); }

# $in{'bbs-no'} �𕪊�
my($fbbsno) = split(/\0/,$in{'bbs-no'});
my($fmoto,$fno) = split(/\-/,$fbbsno);


	# �f���̃��[�h���`�F�b�N
	if($submode2 eq "make" || $submode2 eq "edit"){
		($init_bbs) = Mebius::BBS::init_bbs_parmanent($fmoto);
			if($init_bbs->{'concept'} =~ /(NOT-TAG|MODE-SECRET)/){ main::error("���̌f���ɂ̓^�O��o�^�ł��܂���B"); }
	}

	# �e��`�F�b�N
	if(!$postflag && $submode2 eq "make"){ &error("GET���M�͏o���܂���B"); }
	if(!$admin_mode && !$idcheck && $main::device{'level'} < 2){ &error("�^�O��o�^����ɂ́A�A�J�E���g�Ƀ��O�C�����Ă��������B"); }
	if($submode1 eq "make"){
		if($in{'bbs-no'} eq ""){ &error("�L���A�f�����w�肵�Ă��������B"); }
	}

	# �o�^�̏ꍇ�A�^�O�̓��͓��e���`�F�b�N
	if($submode2 eq "make"){
		require "${int_dir}regist_allcheck.pl";
			if(length($tagname) > $maxlength_tag*2){ &error("�S�p$maxlength_tag�����ȓ��œo�^���Ă��������B"); }
			if($tagname =~ /ttp/){ &error("�t�q�k�͓o�^�ł��܂���B"); }
		&url_check("",$tagname);
		&badword_check($tagname);
		&error_view();
	}

	# �^�O�̐��`
	if($submode2 =~ /(make|delete|edit)/){
		($tagname) = Mebius::Tag::FixTag(undef,$tagname);
			if($tagname eq ""){ &error("�^�O�̓��e����͂��Ă��������B"); }
	}

# ���b�N�J�n
&lock("TAG") if($lockkey);

# �G���R�[�h
my($enctagname) = Mebius::Encode("",$tagname);

	# �L���^�O�t�@�C���̏����������ꍇ�i�폜�j
	if($admin_mode && $submode2 eq "delete" && $in{'place'} eq "thread"){
		&open_threadtag("$submode2 RENEW",$tagname,$enctagname,$fmoto,$fno);
	}

	# �^�O�P�̃t�@�C���̏����������ꍇ�i�o�^���j
	else{
		($flag1,$line1,$tagnum) = &open_tag("$submode2",$tagname,$enctagname,$fmoto,$fno);
	}


# ���b�N����
&unlock("TAG") if($lockkey);

# �V���^�O�t�@�C�����X�V
if($type =~ /make/){ $plustype = " NEWLIST"; }
require "${main::int_dir}part_newlist.pl";
Mebius::Newlist::tag("RENEW$plustype","","","$tagname<>$enctagname<>$tagnum");

	# �W�����v��i�L���f�[�^�ɖ߂�ꍇ�j
	if($admin_mode){ $jump_url = "${main::jak_url}$fmoto.cgi?mode=view&no=$fno&r=data"; }
	else{ $jump_url = "http://$server_domain/_$fmoto/${fno}_data.html"; }

	# ���_�C���N�g��i�^�O�ɖ߂�ꍇ�j
	if($in{'place'} eq "tag"){
		if($admin_mode){ $jump_url = "$main::main_url?mode=tag-p-v-$enctagname"; }
		else{ $jump_url = "http://$server_domain${main_url}tag-p-v-$enctagname.html"; }
	}

	# �N�b�L�[���Z�b�g
	if(!$admin_mode){

		# �N�b�L�[���Z�b�g
		#&set_cookie();

		# ���e�����t�@�C�����X�V
		Mebius::HistoryAll("Renew My-file");

	}

	# ���_�C���N�g
	Mebius::Redirect("",$jump_url);


# HTML
my $print = qq(
���s���܂����B�i<a href="$jump_url">���߂�</a>�j
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# �^�O�P�̃t�@�C���̏���
#-----------------------------------------------------------
sub open_tag{


# �Ǐ���
my($type,$tagname,$enctagname,$moto,$no) = @_;
my($line1,@line2,$i,$nextflag,$title,$sub,$delete_hit,$flag2,$posthandle,$hostagent,$open);
my($init_directory) = Mebius::BaseInitDirectory();
our(%in,$server_domain);

# �^�O�̋��ʐݒ����荞��
my($maxtag,$maxlength_tag) = &getinit_tag_base();

# �����`�F�b�N
$no =~ s/\D//g;
$moto =~ s/[^a-z0-9]//g;
	if($enctagname eq ""){ &error("�^�O���w�肵�Ă��������B"); }

	# CSS��`
	if($type =~ /VIEW/){
		$main::css_text .= qq(table.tag{width:100%;});
	}

# �t�@�C����`
my $file = "${init_directory}_tag/${enctagname}_tag.cgi";
my $move_from_file = "${init_directory}_tag_move_from/${enctagname}_tag.cgi";

# �^�O�P�̃t�@�C�����J��
$open = open(TAG_IN,"<",$file);

chomp(my $top = <TAG_IN>);
my($key,$res,$posttime,$lasttime,$concept) = split(/<>/,$top);


	# �ҏW�A�폜�Ń^�O�t�@�C�������݂��Ȃ��ꍇ
	if( ( ($type =~ /(delete)/ && $in{'place'} eq "tag") || ($type =~ /(edit)/) ) && !$open){
		close(TAG_IN);
		&error("���̃^�O�͑��݂��܂���B");
	}

	# �L�[�`�F�b�N
	if(($key eq "close" || $key eq "lock") && ($type =~ /make/) && !$admin_mode){ &error("���̃^�O�͕��i�܂��̓��b�N�j����Ă��邽�߁A�o�^�ł��܂���B"); }

# �t�@�C����W�J
	while(<TAG_IN>){
		chomp;
		my($moto2,$no2,$sub2,$title2,$account2,$posthandle2,$host2,$server_domain2,$cnumber2,$agent2) = split(/<>/);
		my($hit);

			if($server_domain2 eq ""){ $server_domain2 = $server_domain; }

			# �閧�Ȃǂ��G�X�P�[�v
			if($moto2 =~ /^sc/){ next; }

			# �L���f�[�^�ւ̃^�O�o�^�H
			#if($type =~ /make/){
			#		if("$moto-$no" eq "$moto2-$no2"){ next; }	# �d���o�^�̏ꍇ�͎��񏈗���
			#	if(-e "${init_directory}_tag/$enctagname\_tag.cgi"){ main::error(""); }
			#	main::error("${init_directory}_tag/$enctagname\_tag.cgi");
			#	&open_threadtag("$type RENEW",$tagname,$enctagname,$moto2,$no2);
			#}

			# �u�^�O�P�̃t�@�C���v�̑��삩��A�����́u�L���^�O�v����đ���
			elsif($type =~ /(delete)/ && $admin_mode && $in{'place'} eq "tag"){
			my($flag,$hit);
			foreach(split(/\0/,$in{'bbs-no'})){
			if("$_" eq "$moto2-$no2"){
			($flag,$hit) = &open_threadtag("$type RENEW",$tagname,$enctagname,$moto2,$no2);
			if($admin_mode){ $hit = 1; }
			if($hit){ $delete_hit = 1; }
			}
			}
			if($hit){ next; }
			}

			# �u�^�O�P�̃t�@�C���v�̒��́u�L���o�^�v���A���ʂɂP�폜
			elsif($type =~ /(delete)/ && $admin_mode && $in{'place'} eq "thread"){
			if("$moto-$no" eq "$moto2-$no2"){ $delete_hit++; next; }
			}

		# ��������s
		$i++;
		push(@line2,"$moto2<>$no2<>$sub2<>$title2<>$account2<>$posthandle2<>$host2<>$server_domain2<>$cnumber2<>$agent2<>\n");

			# �^�O���X�g
			if($type =~ /VIEW/){
				my($link);
				$link = "/_$moto2/$no2.html";
				if($admin_mode){ $link = "$moto2.cgi?mode=view&amp;no=$no2"; }
				if($type =~ /MOBILE/){ $line1 .= qq(<li>); } else{ $line1 .= qq(<tr>); }
				if($admin_mode){ $line1 .= qq(<td><input type="checkbox" name="bbs-no" value="$moto2-$no2"></td>); }
				if($type =~ /MOBILE/){ $line1 .= qq(<a href="/_$moto2/$no2.html">$sub2</a> [ <a href="/_$moto2/$no2\_data.html#TAG">�^�O</a> ] - <a href="/_$moto2/">$title2</a>); }
				else{ $line1 .= qq(<td class="sub"><a href="$link">$sub2</a></td><td><a href="/_$moto2/$no2\_data.html#TAG">�^�O</a> </td><td><a href="/_$moto2/">$title2</a></td>); }
				if($idcheck || $admin_mode){
				if($type =~ /MOBILE/){ $line1 .= qq( - <a href="${auth_url}$account2/">$account2</a>); } 
				else{ $line1 .= qq(<td><a href="${auth_url}$account2/">$account2</a></td>); }
			}

			# �z�X�g���̕\��
			if($admin_mode && $admy_rank >= $master_rank){
				$line1 .= qq(<td><a href="$mainscript?mode=cdl&amp;file=$host2&amp;filetype=host" class="manage">$host2</a></td>);
			}

			# �Ǘ��ԍ��̕\��
			if($admin_mode){
				$line1 .= qq(<td><a href="$mainscript?mode=cdl&amp;file=$cnumber2&amp;filetype=number" class="manage">$cnumber2</a></td>);
			}

			# ���[�U�[�G�[�W�F���g�̕\��
			if($admin_mode){
				$line1 .= qq(<td><a href="$mainscript?mode=cdl&amp;file=$agent2&amp;filetype=agent" class="manage">$agent2</a></td>);
			}


			if($type =~ /MOBILE/){ $line1 .= qq(</li>\n); }
			else{ $line1 .= qq(</tr>\n); }
		}
	}
close(TAG_IN);

	# ���X�g���`
	if($line1){
			if($type =~ /MOBILE/){ $line1 = qq(<ul>$line1</ul>); }
			else{
				$line1 = qq(<table summary="�^�O�ꗗ" class="tag">$line1</table>);
			}
	}

	# �A�����M����
	if($submode2 eq "make" && !$pmfile){ &redun("TAG_MAKE",1*60,10); }
	#elsif($submode2 eq "delete"){ &redun("TAG_DELETE",1*60*3,10); }

	# �L���^�O�t�@�C����V�K�o�^
	if($type =~ /make/){
		($none,$none,$none,$none,$sub,$posthandle) = &open_threadtag("$type RENEW",$tagname,$enctagname,$moto,$no);
	}

	# �f�������擾
	if($type =~ /make/){
		#require "${init_directory}part_autoinit.cgi";
		#($title) = &get_autoinit($moto);
		my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);
		($title) = $init_bbs->{'title'};
	}

# UA�L�^�U�蕪��
my $record_agent = $agent if($main::k_access);

	# �ǉ�����s
	if($type =~ /make/){ unshift(@line2,"$moto<>$no<>$sub<>$title<>$pmfile<>$posthandle<>$host<>$server_domain<>$cnumber<>$record_agent<>\n"); $i++; }

	# �L�[��ύX
	if($type =~ /edit/){
			if($in{'type'} eq "lock" && $key ne "lock"){ $key = "lock"; }
			elsif($in{'type'} eq "close" && $key ne "close"){ $key = "close"; }
			else{ $key = "1"; }
	}

	# �g�b�v�f�[�^��ǉ��i�����̃^�O�̏ꍇ�j
	if($top){ unshift(@line2,"$key<>$i<>$posttime<>$time<>$concept<>\n"); }

	# �g�b�v�f�[�^��ǉ��i�V�K�^�O�̏ꍇ�j
	else{ unshift(@line2,"1<>$i<>$time<>$time<>\n"); }

	# �^�O�P�̃t�@�C�����X�V
	if($type !~ /VIEW/){
		my $tag_file = "${init_directory}_tag/$enctagname\_tag.cgi";
			if($type =~ /(make|edit)/ || ($type =~ /delete/ && $delete_hit)){
				#Mebius::Fileout();	
				open(TAG_OUT,">","${init_directory}_tag/$enctagname\_tag.cgi");
				print TAG_OUT @line2;
				close(TAG_OUT);
				Mebius::Chmod(undef,$tag_file);
			}
	}

	# �t�H�[��
	if($type =~ /VIEW/ && $admin_mode && $i >= 1){
		$line1 = qq(
		<form action="$script" method="post">
		<div>
		$line1
		<input type="hidden" name="mode" value="tag-delete"$xclose>
		<input type="hidden" name="tagname" value="$tagname"$xclose>
		<input type="hidden" name="place" value="tag"$xclose>
		<br$xclose><input type="submit" value="�^�O���폜����"$xclose>
		</div>
		</form>
		);
	}

	# �^�O�����`
	if(!$i){ $i = 0; }

# ���^�[��
return($top,$line1,$i,$key,$delete_hit);

}

#-----------------------------------------------------------
# �L���^�O�t�@�C��������
#-----------------------------------------------------------
sub open_threadtag{

# �Ǐ���
my($type,$tagname,$enctagname,$moto,$no,$thread_key) = @_;
my($flag,$line1,$line2,$i,$device,$put_count,$delete_hit);
my($none,$sub,$res,$key,$posthandle,$filehandle3);
our($concept);

	# �����`�F�b�N
	if(!$admin_mode && $type =~ /vanish/){ &error("���̃A�N�V�������o����̂͊Ǘ��҂݂̂ł��B"); }

# �^�O�̋��ʐݒ����荞��
my($maxtag,$maxlength_tag) = &getinit_tag_base();

# �����`�F�b�N
$no =~ s/\D//g;
$moto =~ s/[^a-z0-9]//g;
if($no eq "" || $moto eq ""){ &error("�L�����w�肵�Ă��������B"); }

# �f���ݒ���擾
my($bbs_file) = Mebius::BBS::InitFileName(undef,$moto);

# �t�@�C����`
my $directory1 = "$bbs_file->{'data_directory'}_tag_${moto}/";
my $file1 = "${directory1}${no}_tag.cgi";

	# ���^�[��
	if(!$admin_mode){
		if($moto =~ /^sc/ || $secret_mode || $concept =~ /NOT-TAG/){ return; }
	}

	# CSS��`
	if($type =~ /VIEW/){
		$css_text .= qq(div.tag{margin-top:0.5em;line-height:1.2;});
	}

	# ���L�����J��
	if($type =~ /(RENEW)/){
		my($thread) = Mebius::BBS::thread_state($no,$moto);
			if(!$thread->{'f'}){ &error("���̋L�������݂��܂���B") ; }
		($sub,$res,$key) = ($thread->{'sub'},$thread->{'res'},$thread->{'key'});
		$posthandle = $thread->{'res'}; #��̏����H
		close(THREAD_IN);
	}

	# ���L���̃L�[����
	if($type =~ /make/ && !$admin_mode){
		if($key ne "1" && $key ne "2" && $key ne "3" && $key ne "5"){ &error("�폜�ς݁A���b�N���L���̃^�O�͕ҏW�ł��܂���B"); }
	}

	# �\�����[�h
	if($type =~ /MOBILE/){ $device = "k"; } else { $device = "p"; }


# �t�@�C�����J��
open($filehandle3,"<$file1");
my $top = <$filehandle3>; chomp $top;
my($key,$res) = split(/<>/,$top);

	# �t�@�C����W�J
	while(<$filehandle3>){
		chomp;
		my($count2,$tagname2,$server_domain2) = split(/<>/);
		my($enctagname2) = Mebius::Encode("",$tagname2);

			if($server_domain2 eq ""){ $server_domain2 = $server_domain; }

			# �L���ɓo�^����Ă���A�S�Ắu�^�O�P�̃t�@�C���v���폜���鏈���ֈڍs
			if($type =~ /vanish/){
				($none,$none,$none,$none,$hit) = &open_tag("delete RENEW",$tagname2,$enctagname2,$moto,$no);
				$delete_hit++; next;
			}

			# ���ʂɍ폜
			elsif($type =~ /delete/ && $admin_mode && $in{'place'} eq "tag"){
				if($tagname2 eq $tagname){ $delete_hit++; next; }
			}

			# �����̃^�O�t�@�C������Ăɍ폜
			elsif($type =~ /delete/ && $admin_mode && $in{'place'} eq "thread"){
				my($none,$hit);
				foreach(split(/\0/,$in{'tagname'})){
						if($tagname2 eq $_){
							($none,$none,$none,$none,$hit) = &open_tag("$type RENEW",$tagname2,$enctagname2,$moto,$no);
								if($admin_mode){ $hit = 1; }
								if($hit){ $delete_hit = 1; }
						}
				}
					if($hit){ next; }
			}

		$i++;

			# �o�^�ő吔�I�[�o�[
			if($i > $maxtag && $type =~ /make/){
				&error("�ЂƂ̋L���ɁA�o�^�ł���^�O��$maxtag�܂łł��B$in{'no'}\(���� $i �� \) �L��");
			}

			if($tagname2 eq $tagname){ $flag = 1; }
			else{ $line2 .= qq($count2<>$tagname2<>$server_domain2<>\n); }
			if($admin_mode){ $line1 .= qq(<input type="checkbox" name="tagname" value="$tagname2">); }
			if($admin_mode){ $line1 .= qq(<a href="$mainscript?mode=tag-$device-v-$enctagname2">$tagname2</a> ); }
			else{ $line1 .= qq(<a href="/_main/tag-$device-v-$enctagname2.html">$tagname2</a> ); }

	}

close($filehandle3);

	# �L�[�`�F�b�N
	if($key eq "close" || $key eq "lock"){ &error("���̋L���ɂ̓^�O��o�^�ł��܂���B"); }

	# �ǉ�����s
	if($type =~ /make/){ $line2 = qq(1<>$tagname<>$server_domain<>\n) . $line2; $i++; }

	# �g�b�v�f�[�^��ǉ��i�����̃^�O�̏ꍇ�j
	if($top){ $line2 = qq($key<>$i<>\n) . $line2; }

	# �g�b�v�f�[�^��ǉ��i�V�K�o�^�̏ꍇ�j
	else{ $line2 = qq(1<>$i<>\n) . $line2; }

	# ���` ( �L�����̃^�O )
	if($type =~ /VIEW/){

			if($type =~ /THREAD/){
	#if($line1 eq "" && $thread_key ne "3"){ $line1 = qq(�^�O�͂܂�����܂���B<a href="$in{'no'}_data.html">�L���f�[�^</a>����o�^���Ă��������B); } 
			}

			# ���`
			if($line1){
					if($admin_mode){ $taglink = qq(<a href="$script?mode=view&amp;no=$in{'no'}&amp;r=data">�^�O</a> �F ); }
					else{ $taglink = qq(<a href="$in{'no'}_data.html">�^�O</a> �F ); }
			}

			# ���`
			if($line1){
				my($tagsearch_form) = &get_tagsearch_form("THREAD");
					if($type =~ /THREAD/){ $line1 = qq($taglink$line1); }
			}
			else{
				my($tagsearch_form) = &get_tagsearch_form("THREAD");
					if($type =~ /THREAD/){ $line1 = qq($taglink); }
			}
	}

# �t�H�[�����`
if($admin_mode && $line1 && $type =~ /FORM/){
$line1 = qq(
<form action="$mainscript" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="tag-delete">
<input type="hidden" name="bbs-no" value="$moto-$no">
<input type="hidden" name="place" value="thread">
$line1
<input type="submit" name="submit" value="�^�O���폜����">
</div>
</form>
);
}

	# �u�L���^�O�v�t�@�C�����X�V
	if($type =~ /RENEW/ && ($type =~ /(make|edit)/ || ($type =~ /(delete)/ && $delete_hit)) ){
		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);
		# �t�@�C���X�V
		Mebius::Fileout(undef,$file1,$line2);
	}

# �u�L���^�O�v�t�@�C�����폜
if($type =~ /vanish/){ unlink($file1); }

# ���^�[��
return($top,$delete_hit,$line1,$i,$sub,$posthandle);

}


#-----------------------------------------------------------
# �^�O�����t�H�[��
#-----------------------------------------------------------
sub get_tagsearch_form{

# �錾
my($type) = @_;
my($line,$submode2);

	# ��`
	if($main::kflag){ $submode2 = "k"; }
	else{ $submode2 = "p"; }

	# �t�H�[�J�X�𓖂Ă�
	if($type =~ /FOCUS/){
$main::body_javascript = qq( onload="document.TAGSEARCH.word.focus()");
	}

	# CSS��`�i�X���b�h�\���j
	if($type =~ /THREAD/){
$main::css_text .= qq(
form.tagsearch{float:right;text-align:right;margin:auto;vertical-align:top;}
input.tagsearch_input{width:10em;border:color:#044;}
);
	}

# �t�H�[�����e���`
$line = qq(
<form action="$main::main_url" name="TAGSEARCH" id="TAGSEARCH" class="tagsearch inline">
<div class="inline">
<input type="hidden" name="mode" value="newtag-$submode2-1">
<input type="text" name="word" value="$main::in{'word'}" class="tagsearch_input">
<input type="submit" value="�^�O����">
</div>
</form>
);

# ���^�[��
return($line);
}



1;
