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
      <h3>Давайте общаться! 💬</h3>
      <p style={{ fontSize: '1.1rem', marginBottom: '1rem', opacity: 0.9 }}>
        А чтобы быть ближе друг к другу уже сейчас, мы открыли уютный чат – пространство для общения, тёплых слов и вопросов 
        {/* Присоединяйтесь к нашему чату в Telegram — делитесь впечатлениями, 
        задавайте вопросы и будьте в курсе всех деталей! */}
      </p>
      <div ref={qrRef} className="qr-wrapper"></div><br/>
      <a href={telegramLink} target="_blank" rel="noopener noreferrer" className="telegram-button">
        {/* <img src="/telegram.png" alt="" className="telegram-icon" /> */}
        <svg xmlns="http://www.w3.org/2000/svg" className="telegram-icon" viewBox="0 0 640 640"><path d="M127.5 127.5C96 159 96 209.7 96 311L96 329C96 430.3 96 481 127.5 512.5C159 544 209.7 544 311 544L328.9 544C430.3 544 481 544 512.4 512.5C543.8 481 544 430.3 544 329L544 311.1C544 209.7 544 159 512.5 127.6C481 96.2 430.3 96 329 96L311 96C209.7 96 159 96 127.5 127.5zM171.6 232.3L222.7 232.3C224.4 317.8 262.1 354 292 361.5L292 232.3L340.2 232.3L340.2 306C369.7 302.8 400.7 269.2 411.1 232.3L459.3 232.3C455.4 251.5 447.5 269.6 436.2 285.6C424.9 301.6 410.5 315.1 393.7 325.2C412.4 334.5 428.9 347.6 442.1 363.7C455.3 379.8 465 398.6 470.4 418.7L417.4 418.7C412.5 401.2 402.6 385.6 388.8 373.7C375 361.8 358.1 354.3 340.1 352.1L340.1 418.7L334.3 418.7C232.2 418.7 174 348.7 171.5 232.2z"/></svg>
        <span>Присоединиться к чату</span>
      </a>
    </div>
  );
};

export default TelegramQR;

