import React, { useState, useEffect } from 'react';
import Schedule from './Schedule';
import GuestForm from './GuestForm';
import TelegramQR from './TelegramQR';
import './EventInfo.css';

const EventInfo = () => {
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
    <section className="event-info">
      <div className="event-overlay">
        <div className="event-content">
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

          <p>
            <strong>18.07.2026 в 10:00</strong>
          </p>

          <h3>О подарках</h3>
          <p>Ваше присутствие — лучший подарок для нас! Но если хотите порадовать нас чем-то особенным, мы будем благодарны за вклад в наше совместное будущее 💝</p>

          <Schedule />

          <h3>Подтвердите участие</h3>
          <p>
            Пожалуйста, дайте нам знать о своих планах до <strong>1 января 2025</strong> — 
            так мы сможем всё подготовить идеально!
            <br />
          </p>

          <GuestForm />

          <TelegramQR />
        </div>
      </div>
    </section>
  );
};

export default EventInfo;

