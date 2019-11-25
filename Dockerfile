FROM ubuntu:latest

RUN apt-get update && \
		apt-get install -y --no-install-recommends vsftpd db-util && \
		apt-get clean

ENV FTP_USER admin
ENV FTP_PASS admin
ENV FTP_ANON NO
ENV PASV_ADDRESS 127.0.0.1
ENV PASV_MIN_PORT 47400
ENV PASV_MAX_PORT 47470
ENV PASV_ADDR_RESOLVE NO
ENV PASV_ENABLE YES

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh && \
		mkdir -p /var/run/vsftpd/empty

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21

CMD ["/usr/sbin/run-vsftpd.sh"]
