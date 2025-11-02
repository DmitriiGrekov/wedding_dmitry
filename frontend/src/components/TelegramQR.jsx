import React, { useEffect, useRef } from 'react';
import QRCodeStyling from 'qr-code-styling';
import './TelegramQR.css';

const TelegramQR = ({ telegramLink = 'https://t.me/ВАША_ССЫЛКА_НА_ГРУППУ' }) => {
  const qrRef = useRef(null);
  const qrCodeRef = useRef(null);

  useEffect(() => {
    if (!qrCodeRef.current) {
      qrCodeRef.current = new QRCodeStyling({
        width: 200,
        height: 200,
        data: telegramLink,
        image: '',
        dotsOptions: {
          color: '#ecfbff',
          type: 'rounded'
        },
        backgroundOptions: {
          color: 'transparent'
        },
        cornersSquareOptions: {
          type: 'extra-rounded',
          color: '#ecfbff'
        }
      });
    }

    if (qrRef.current) {
      qrRef.current.innerHTML = '';
      qrCodeRef.current.append(qrRef.current);
    }
  }, [telegramLink]);

  return (
    <div className="telegram-qr">
      <h3>Присоединяйтесь к нашей группе в Telegram</h3>
      <div ref={qrRef} className="qr-wrapper"></div><br/>
      <a href={telegramLink} target="_blank" rel="noopener noreferrer" className="telegram-button">
        Перейти в Telegram
      </a>
    </div>
  );
};

export default TelegramQR;

