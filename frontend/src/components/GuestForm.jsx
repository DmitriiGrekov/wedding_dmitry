import React, { useState } from 'react';
import './GuestForm.css';

const GuestForm = () => {
  const [guests, setGuests] = useState([{ lastName: '', firstName: '' }]);
  const MAX_GUESTS = 4;

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

  const handleSubmit = (e) => {
    e.preventDefault();
    
    const filledGuests = guests
      .filter((guest) => guest.lastName.trim() || guest.firstName.trim())
      .map((guest) => `${guest.lastName.trim()} ${guest.firstName.trim()}`.trim());

    if (filledGuests.length === 0) {
      alert('Пожалуйста, введите хотя бы одного гостя!');
      return;
    }

    alert(`Спасибо! Вы подтвердили участие для следующих гостей:\n\n${filledGuests.join('\n')}`);
    
    // Сброс формы
    setGuests([{ lastName: '', firstName: '' }]);
  };

  return (
    <form id="guests-form" onSubmit={handleSubmit}>
      <div id="guest-list">
        {guests.map((guest, index) => (
          <div key={index} className="guest-input">
            <input
              type="text"
              placeholder="Фамилия"
              value={guest.lastName}
              onChange={(e) => handleInputChange(index, 'lastName', e.target.value)}
              required
            />
            <input
              type="text"
              placeholder="Имя"
              value={guest.firstName}
              onChange={(e) => handleInputChange(index, 'firstName', e.target.value)}
              required
            />
            {guests.length > 1 && (
              <button
                type="button"
                className="remove-guest-btn"
                onClick={() => handleRemoveGuest(index)}
                title="Удалить гостя"
              >
                ✕
              </button>
            )}
          </div>
        ))}
      </div>
      <button type="button" className="add-guest-btn" onClick={handleAddGuest}>
        Добавить гостя
      </button>
      <button type="submit" className="submit-btn">
        Подтвердить
      </button>
    </form>
  );
};

export default GuestForm;

