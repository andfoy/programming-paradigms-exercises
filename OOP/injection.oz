local MailClient SMTPMailSender SMTPSMailSender POP3MailReciever IMAPMailReciever MailProtocol MailSender MailReciever in
   class MailProtocol from BaseObject
      attr username password server port
      meth init(User Pass Host Port)
	 username := User
	 password := Pass
	 server := Host
	 port := Port
      end
   end

   class MailSender from MailProtocol
      meth send(Mail To)
         {self noop}
      end
   end

   class MailReciever from MailProtocol
      meth retrieve($)
	 {self noop}
	 nil
      end
   end

   class SMTPMailSender from MailSender
      meth send(Mail To)
	 {Show 'Sending mail with SMTP (Insecure)'}
	 {Show @server}
	 {Show @port}
	 {Show @username}
	 {Show @password}
	 {Show Mail}
	 {Show To}
      end
   end

   class SMTPSMailSender from MailSender
      meth send(Mail To)
	 {Show 'Sending mail with SMTPS (secure)'}
	 {Show @server}
	 {Show @port}
	 {Show Mail}
	 {Show To}
      end
   end

   class IMAPMailReciever from MailReciever
      meth retrieve($)
	 {Show 'Retrieving incoming mail using IMAP'}
	 ['Mail 1' 'Mail 2']
      end
   end

   class POP3MailReciever from MailReciever
      meth retrieve($)
	 {Show 'Retrieving incoming mail using POP3'}
	 ['POP1' 'POP2']
      end
   end

   class MailClient
      attr sender reciever
      meth init(Sender Reciever)
	 sender := Sender
	 reciever := Reciever
      end
      
      meth sendMail(Text To)
	 {@sender send(Text To)}
      end

      meth retrieveMail($)
         {@reciever retrieve($)}
      end

      meth setSender(Sender)
         sender := Sender
      end

      meth setReciever(Reciever)
	 reciever := Reciever
      end
   end

   local SecureSender InsecureSender PReciever IReciever Client in
      SecureSender = {New SMTPSMailSender init('user' 'pass' 'mail.com' 587)}
      InsecureSender = {New SMTPMailSender init('user' 'pass' 'mail.com' 25)}
      PReciever = {New POP3MailReciever init('user' 'pass' 'mail.com' 110)}
      IReciever = {New IMAPMailReciever init('user' 'pass' 'mail.com' 143)}
      Client = {New MailClient init(InsecureSender PReciever)}
      {Client sendMail('Insecure text' 'steal@mail.com')}
      {Show {Client retrieveMail($)}}
      {Client setSender(SecureSender)}
      {Client sendMail('Secure text' 'fortress@mail.com')}
      {Client setReciever(IReciever)}
      {Show {Client retrieveMail($)}}
   end
end