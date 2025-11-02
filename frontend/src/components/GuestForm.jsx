import React, { useState } from 'react';
import './GuestForm.css';

const GuestForm = () => {
  const [guests, setGuests] = useState([{ lastName: '', firstName: '' }]);
  const [loading, setLoading] = useState(false);
  const [submitStatus, setSubmitStatus] = useState({ type: '', message: '' });
  const MAX_GUESTS = 4;

  // API URL из переменных окружения или дефолтный
  // const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080/api';
  const API_URL = 'http://localhost:8080/api'


  const handleAddGuest = () => {
    if (guests.length >= MAX_GUESTS) {
      alert(`Можно добавить максимум ${MAX_GUESTS} гостей.`);
      return;
    }
    setGuests([...guests, { lastName: '', firstName: '' }]);
  };

  const handleRemoveGuest = (index) => {
    const newGuests = guests.filter((_, i) => i !== index);
    setGuests(newGuests);
  };

  const handleInputChange = (index, field, value) => {
    const newGuests = [...guests];
    newGuests[index][field] = value;
    setGuests(newGuests);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Фильтруем только заполненных гостей
    const filledGuests = guests.filter(
      (guest) => guest.lastName.trim() && guest.firstName.trim()
    );

    if (filledGuests.length === 0) {
      setSubmitStatus({
        type: 'error',
        message: 'Пожалуйста, введите хотя бы одного гостя с именем и фамилией!'
      });
      return;
    }

    setLoading(true);
    setSubmitStatus({ type: '', message: '' });

    try {
      // Отправляем каждого гостя на backend
      console.log(API_URL);
      const promises = filledGuests.map(async (guest) => {
        const response = await fetch(`${API_URL}/guests/`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            first_name: guest.firstName.trim(),
            last_name: guest.lastName.trim(),
          }),
        });

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          throw new Error(errorData.detail || `Ошибка при добавлении гостя: ${guest.lastName} ${guest.firstName}`);
        }

        return response.json();
      });

      const results = await Promise.all(promises);
      
      // Формируем список успешно добавленных гостей
      const guestNames = results.map(
        (result) => `${result.last_name} ${result.first_name}`
      ).join('\n');

      setSubmitStatus({
        type: 'success',
        message: `🎉 Спасибо! Вы успешно подтвердили участие для:\n\n${guestNames}\n\nМы с нетерпением ждём вас на нашей свадьбе!`
      });

      // Сброс формы через 3 секунды
      setTimeout(() => {
        setGuests([{ lastName: '', firstName: '' }]);
        setSubmitStatus({ type: '', message: '' });
      }, 5000);

    } catch (error) {
      console.error('Ошибка отправки данных:', error);
      setSubmitStatus({
        type: 'error',
        message: `❌ Произошла ошибка: ${error.message}\n\nПожалуйста, попробуйте ещё раз или свяжитесь с нами.`
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <form id="guests-form" onSubmit={handleSubmit}>
      {/* Сообщение о статусе отправки */}
      {submitStatus.message && (
        <div className={`submit-status ${submitStatus.type}`}>
          {submitStatus.message.split('\n').map((line, i) => (
            <div key={i}>{line}</div>
          ))}
        </div>
      )}

      <div id="guest-list">
        {guests.map((guest, index) => (
          <div key={index} className="guest-input">
            <input
              type="text"
              placeholder="Фамилия"
              value={guest.lastName}
              onChange={(e) => handleInputChange(index, 'lastName', e.target.value)}
              required
              disabled={loading}
            />
            <input
              type="text"
              placeholder="Имя"
              value={guest.firstName}
              onChange={(e) => handleInputChange(index, 'firstName', e.target.value)}
              required
              disabled={loading}
            />
            {guests.length > 1 && (
              <button
                type="button"
                className="remove-guest-btn"
                onClick={() => handleRemoveGuest(index)}
                title="Удалить гостя"
                disabled={loading}
              >
                ✕
              </button>
            )}
          </div>
        ))}
      </div>
      <button 
        type="button" 
        className="add-guest-btn" 
        onClick={handleAddGuest}
        disabled={loading || guests.length >= MAX_GUESTS}
      >
        Добавить гостя
      </button>
      <button 
        type="submit" 
        className="submit-btn"
        disabled={loading}
      >
        {loading ? 'Отправка...' : 'Подтвердить'}
      </button>
    </form>
  );
};

export default GuestForm;

