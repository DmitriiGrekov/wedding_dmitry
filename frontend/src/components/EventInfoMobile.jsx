import React, { useState, useEffect } from 'react';
import GuestForm from './GuestForm';
import TelegramQR from './TelegramQR';
import './EventInfoMobile.css';

const EventInfoMobile = () => {
  const [guestNames, setGuestNames] = useState('Гость');
  const [isPlural, setIsPlural] = useState(false);
  const [gender, setGender] = useState('neutral');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchInvitation = async () => {
      try {
        // Получаем UUID из URL (например, /?uuid=...)
        const urlParams = new URLSearchParams(window.location.search);
        const uuid = urlParams.get('uuid');
        const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080/api';

        if (uuid) {
          const response = await fetch(`${API_URL}/guests/invitations/by-uuid/${uuid}/`);
          
          if (response.ok) {
            const data = await response.json();
            setGuestNames(data.guest_names);
            setIsPlural(data.is_plural);
            setGender(data.gender || 'neutral');
          } else {
            console.error('Приглашение не найдено');
          }
        }
      } catch (error) {
        console.error('Ошибка при загрузке приглашения:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchInvitation();
  }, []);

  // Логика выбора обращения в зависимости от пола и количества
  const getGreeting = () => {
    if (isPlural) {
      return 'Дорогие';
    }
    
    switch (gender) {
      case 'male':
        return 'Дорогой';
      case 'female':
        return 'Дорогая';
      case 'neutral':
      default:
        return 'Дорогой';
    }
  };

  const greeting = getGreeting();

  return (
    <section className="event-info-mobile">
      <div className="event-overlay-mobile">
        {/* Блок приглашения */}
        <div className="event-block invitation-block">
          <h2>
            {loading ? (
              <>Дорогой<br />Гость!</>
            ) : (
              <>
                {greeting}
                <br />
                {guestNames}!
              </>
            )}
          </h2>

          <p>
            Мы начинаем новую главу нашей истории! <strong>18 июля 2026</strong> — день, когда
            мы станем семьей, и нам очень важно разделить эту радость с вами.
            <br />
            Будем счастливы видеть вас на нашем празднике!
          </p>

          <p className="event-date">
            <strong>18.07.2026 в 10:00</strong>
          </p>

          <h3>О подарках</h3>
          <p>Ваше присутствие — лучший подарок для нас! Но если хотите порадовать нас чем-то особенным, мы будем благодарны за вклад в наше совместное будущее 💝</p>
        </div>

        {/* Блок расписания и места проведения */}
        <div className="event-block schedule-block">
          <h2>План празднования</h2>

          <div className="schedule-item-mobile">
            <time>10:00</time>
            <div>
              <strong>Церемония в ЗАГСе</strong>
              <p>
                Самый волнующий момент! Будем рады, если вы разделите 
                с нами эти особенные минуты, когда мы официально станем семьей ✨
              </p>
            </div>
          </div>

          <div className="schedule-item-mobile">
            <time>12:00</time>
            <div>
              <strong>Праздничный банкет</strong>
              <p>
                После церемонии отправляемся отмечать! 
                Трансфер до банкетного зала организован (2 комфортабельных минивэна). 
                Приготовьтесь к веселью, танцам и отличной компании! 🎉
              </p>
            </div>
          </div>

          <h3 className="map-title">Место проведения</h3>
          <div className="map-container">
            <iframe
              src="https://yandex.ru/map-widget/v1/?um=constructor%3Aee33a1ba858e5427672eaf6a7750f77d38e46ea509913d1f14408dd25661533e&amp;source=constructor"
              width="100%"
              height="300"
              frameBorder="0"
              style={{ border: 0, borderRadius: '16px' }}
              allowFullScreen
              title="Место проведения"
            ></iframe>
          </div>
        </div>

        {/* Блок подтверждения участия */}
        <div className="event-block confirmation-block">
          <GuestForm />
        </div>

        {/* Блок Telegram */}
        <div className="event-block telegram-block">
          <TelegramQR />
        </div>
      </div>
    </section>
  );
};

export default EventInfoMobile;

