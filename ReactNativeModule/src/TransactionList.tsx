import React, { useState, useEffect } from 'react';
import { FlatList, NativeModules, NativeEventEmitter, StyleSheet, View, Text } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import TransactionRow from './TransactionRow';
import { colors, fonts } from './theme';

const { TransactionBridge } = NativeModules;
const eventEmitter = new NativeEventEmitter(TransactionBridge);

interface Transaction {
  id: string;
  amount: number;
  type: 'expense' | 'income';
  category: {
    name: string;
    icon: string;
    color: string;
    bgColor: string;
    type: string;
  };
  note: string;
  paidBy: string;
  date: number;
}

interface Props {
  transactions?: Transaction[];
}

export default function TransactionList({ transactions: initialTransactions }: Props) {
  const [transactions, setTransactions] = useState<Transaction[]>(
    initialTransactions || []
  );

  useEffect(() => {
    const subscription = eventEmitter.addListener(
      'onTransactionsUpdate',
      (data: Transaction[]) => {
        setTransactions(data);
      }
    );
    // Listener is now registered — ask native for any cached transactions
    TransactionBridge.requestTransactions();
    return () => subscription.remove();
  }, []);

  const handleDelete = (id: string) => {
    TransactionBridge.deleteTransaction(id);
  };

  return (
    <GestureHandlerRootView>
      <FlatList
        data={transactions}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <TransactionRow
            transaction={{
              ...item,
              date: new Date(item.date),
            }}
            onDelete={handleDelete}
          />
        )}
        contentContainerStyle={transactions.length === 0 ? styles.emptyList : styles.list}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>No transactions yet</Text>
          </View>
        }
      />
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  list: { gap: 12, paddingBottom: 24 },
  emptyList: { flexGrow: 1, justifyContent: 'center', alignItems: 'center' },
  emptyContainer: { alignItems: 'center', paddingVertical: 40 },
  emptyText: { fontSize: 15, fontFamily: fonts.bodyMedium, color: colors.muted },
});
